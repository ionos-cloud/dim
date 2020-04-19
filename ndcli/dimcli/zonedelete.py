from .zoneimport import target_from_fields, toposort
from dimcli import _print_messages


def is_reverse_zone(zone):
    return zone.endswith('in-addr.arpa') or zone.endswith('ip6.arpa')


def absolute_name(name, zone):
    if name.endswith('.'):
        return name
    if zone != '.':
        zone = zone + '.'
    if name == '@':
        return zone
    if zone == '.':
        return name + '.'
    return name + '.' + zone


def toposort_records(records, zone):
    '''
    :type records: list of RR objects
    '''
    # Build the graph
    names = {}
    for i, record in enumerate(records):
        target = target_from_fields(record['value'])
        if target:
            names.setdefault(absolute_name(target, zone), set()).add(i)
    # Sort the graph
    sorted_nodes = toposort(len(records), lambda node: names.get(records[node]['absolute_record'], []))
    return [records[node] for node in sorted_nodes]


def _delete_rrs(server, zone, profile, view, print_messages):
    # Get rrs
    rrs = server.rr_list(zone=zone, profile=profile, view=view, value_as_object=True)
    rrs = [rr for rr in rrs if rr['type'] != 'SOA']
    if not is_reverse_zone(zone):
        for rr in rrs:
            rr['absolute_record'] = absolute_name(name=rr['record'], zone=rr['zone'])
        rrs = toposort_records(rrs, zone=zone)
    # Delete rrs
    for rr in rrs:
        options = rr['value']
        if 'layer3domain' in rr:
            options['layer3domain'] = rr['layer3domain']
        result = server.rr_delete(zone=zone,
                                  name=rr['record'],
                                  type=rr['type'],
                                  profile=profile,
                                  views=[view],
                                  free_ips=True,
                                  references='warn',
                                  **options)
        print_messages(result)


def delete_zone(server, zone, profile, print_messages):
    '''
    Iteratively delete all rrs, then the zone.

    Implemented this way because server.zone_delete(cleanup=True) is too slow.
    '''
    server.zone_delete_check(zone, profile=profile)
    _delete_rrs(server, zone, profile, None, print_messages)
    print_messages(server.zone_delete(zone, profile=profile, cleanup=True))


def delete_zone_view(server, zone, view, print_messages):
    '''
    Iteratively delete all rrs, then the zone.

    Implemented this way because server.zone_delete_view(cleanup=True) is too slow.
    '''
    server.zone_delete_view_check(zone, view)
    _delete_rrs(server, zone, False, view, print_messages)
    print_messages(server.zone_delete_view(zone, view, cleanup=True))
