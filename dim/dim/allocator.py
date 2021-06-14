import random
from collections import namedtuple
from itertools import islice, groupby

from dim import db
from dim.ipaddr import IP
from dim.models import Ipblock, Pool


def allocate_ip(pool_or_block):
    ips = _allocate_from(pool_or_block,
                         version=pool_or_block.version,
                         prefix=32 if pool_or_block.version == 4 else 128,
                         maxsplit=0,
                         allow_hosts=True)
    return ips[0] if ips else None


def allocate_delegation(pool_or_block, prefix, maxsplit):
    return _allocate_from(pool_or_block,
                          version=pool_or_block.version,
                          prefix=prefix,
                          maxsplit=maxsplit,
                          allow_hosts=False)


def _allocate_from(pool_or_block, **kwargs):
    if isinstance(pool_or_block, Pool):
        pool = pool_or_block
        parent_query = Ipblock.query.filter_by(pool=pool, layer3domain=pool.layer3domain)
        strategy = pool.get_attrs().get('allocation_strategy', 'first')
    elif isinstance(pool_or_block, Ipblock):
        block = pool_or_block
        parent_query = Ipblock.query.filter_by(id=block.id, layer3domain=block.layer3domain)
        strategy = block.get_attrs().get('allocation_strategy')
        if strategy is None:
            subnet = block.subnet
            if subnet and subnet.pool:
                strategy = subnet.pool.get_attrs().get('allocation_strategy', 'first')
            else:
                strategy = 'first'
    return allocate(parent_query=parent_query,
                    strategy=strategy,
                    **kwargs)


def allocate(parent_query, version, prefix, maxsplit, strategy, allow_hosts):
    '''
    Returns the shortest list of IP objects representing free space which have
    the same number of addresses as a /`prefix` block. If this is not possible,
    the empty list is returned.

    `strategy` can be ``first`` or ``random``.
    '''
    total_bits = 32 if version == 4 else 128
    if not isinstance(prefix, int) or prefix > total_bits or prefix <= 0:
        raise Exception("Invalid prefix %r" % prefix)
    if not isinstance(maxsplit, int) or maxsplit < 0:
        raise Exception("Invalid maxsplit: %r" % maxsplit)

    free = free_ranges(parent_query)
    # pprint([[(ipstr(f[0]), ipstr(f[1])) for f in l] for l in free])
    selected = []
    # minblock is the smallest block that can be returned (/prefix+maxsplit)
    # needed is number of minblocks missing from selected
    needed = 2 ** maxsplit
    # Try to satisfy the request by selecting the biggest blocks first
    for splitbits in range(maxsplit + 1):
        subprefix = prefix + splitbits
        if not allow_hosts and subprefix == total_bits:
            break
        subblocks = 2 ** (maxsplit - splitbits)  # nr of minblocks in a /subprefix block
        for ranges in free:
            blocks = substract_blocks(ranges, needed // subblocks, subprefix, version, strategy)
            needed -= subblocks * len(blocks)
            selected.extend(blocks)
            if needed < subblocks:
                break
        if needed == 0:
            return selected
        assert needed > 0
    return []


def free_ranges(parent_query):
    '''
    Returns the list of ranges representing the free space in `parent_query`
    grouped by parent block.
    '''
    parents = dict((p.id, IP(int(p.address), p.prefix, p.version)) for p in parent_query.all())
    psq = parent_query.subquery()
    used = db.session.query(psq.c.id, Ipblock.address, Ipblock.prefix)\
        .outerjoin(Ipblock, Ipblock.parent_id == psq.c.id)\
        .order_by(psq.c.priority, psq.c.id, Ipblock.address).all()
    result = []
    for pid, children in groupby(used, key=lambda x: x[0]):
        parent = parents[pid]
        range_start = parent.network.address
        ranges = []
        for _, address, prefix in children:
            if address is None:
                continue
            address = int(address)
            # Process the range before child
            range_end = address - 1
            if range_start <= range_end:
                ranges.append([range_start, range_end])
            # Prepare for the next range
            range_start = address + 2 ** (parent.bits - prefix)
        # Process the range after the last child
        range_end = parent.broadcast.address
        if range_start <= range_end:
            if range_start == parent.network.address:
                # We need to split the range if we had no children, otherwise we
                # could try to allocate a child with the same prefix, which is not
                # possible
                mid = ((range_end - range_start + 1) % 2 + range_start)
                ranges.append([range_start, mid - 1])
                ranges.append([mid, range_end])
            else:
                ranges.append([range_start, range_end])
        result.append(ranges)
    return result


def align(number, to):
    rest = number % to
    if rest:
        return number + to - rest
    else:
        return number


def ipstr(nr, version=4):       # debugging helper
    return str(IP(nr, version=version))


def blocks_in_range(range_, prefix, total_bits, version):
    range_start, range_end = range_
    numaddrs = 2 ** (total_bits - prefix)
    block_start = align(range_start, numaddrs)
    block_end = block_start + numaddrs - 1
    while block_end <= range_end:
        yield IP(block_start, prefix, version)
        block_start = block_end + 1
        block_end += numaddrs


def random_sample(n, k):
    result = [None] * k
    selected = set()
    for i in range(k):
        j = int(random.random() * n)
        while j in selected:
            j = int(random.random() * n)
        result[i] = j
        selected.add(j)
    return result


def remove_blocks(ranges, ir, blocks):
    '''
    Remove `blocks` from the `ir`th range in `ranges`. This might require
    splitting the `ir`th range multiple times.

    `blocks` must be sorted.
    '''
    for block in blocks:
        assert ranges[ir][0] <= block.address <= ranges[ir][1]
        if block.address == ranges[ir][0]:
            ranges[ir][0] = block.broadcast.address + 1
        else:
            new_start = block.broadcast.address + 1
            new_end = ranges[ir][1]
            ranges[ir][1] = block.network.address - 1
            ir = len(ranges)
            ranges.append([new_start, new_end])


CandidateRange = namedtuple('CandidateRange', ['start', 'end', 'count', 'range'])


def substract_blocks(ranges, maxnr, prefix, version, strategy):
    '''
    Returns at most `maxnr` /`prefix` blocks from `ranges`.
    '''
    if strategy not in ('first', 'random'):
        raise Exception('Invalid allocation strategy %r' % strategy)
    total_bits = 32 if version == 4 else 128

    def substract_first():
        ret = []
        still_needed = maxnr
        for i in range(len(ranges)):
            blocks = list(islice(blocks_in_range(ranges[i], prefix, total_bits, version), still_needed))
            remove_blocks(ranges, i, blocks)
            ret.extend(blocks)
            still_needed -= len(blocks)
            assert still_needed >= 0
            if still_needed < 0:
                still_needed = 0
            if still_needed == 0:
                break
        ranges.sort()
        return ret

    def substract_random():
        # Collect candidate ranges
        candidates = []
        numaddrs = 2 ** (total_bits - prefix)
        for i in range(len(ranges)):
            range_start, range_end = ranges[i]
            start = align(range_start, numaddrs)
            count = (range_end - start + 1) // numaddrs
            if count > 0:
                candidates.append(CandidateRange(start, range_end, count, i))

        # Get a random sample of at most maxnr block positions
        nr_candidates = sum(c.count for c in candidates)
        if nr_candidates == 0:
            return []
        if maxnr >= nr_candidates:
            positions = list(range(nr_candidates))
        else:
            positions = random_sample(nr_candidates, maxnr)

        # Return IP objects for the selected positions
        cid = 0                 # current CandidateRange id
        sofar = 0               # number of blocks until cid
        result = []
        to_remove = {}
        for i in sorted(positions):
            # Advance cid until we get to block i
            while i - sofar >= candidates[cid].count:
                sofar += candidates[cid].count
                cid += 1
                assert cid < len(candidates)
            block = IP(candidates[cid].start + (i - sofar) * numaddrs,
                       prefix,
                       version)
            result.append(block)
            to_remove.setdefault(candidates[cid].range, []).append(block)
        for i, blocks in list(to_remove.items()):
            remove_blocks(ranges, i, blocks)
        return result

    if strategy == 'first':
        return substract_first()
    elif strategy == 'random':
        return substract_random()
