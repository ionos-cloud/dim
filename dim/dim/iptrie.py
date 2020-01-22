class TrieNode(object):
    __slots__ = ('left', 'right', 'data')

    def __init__(self, left=None, right=None, data=None):
        self.left = left
        self.right = right
        self.data = data

    def __getstate__(self):
        return (self.left, self.right, self.data)

    def __setstate__(self, state):
        self.left, self.right, self.data = state


class Trie(object):
    def __init__(self, bits):
        self._bits = bits
        self._root = TrieNode()

    def find(self, addr, size, data=None, update=False, delete=False):
        '''
        Returns a tuple with the data for the node and its "parent".  The
        "parent" is the closest ancestor with data.
        '''
        parent = pred = node = self._root
        for i in range(self._bits - 1, self._bits - size - 1, -1):
            if node is None:
                break
            # pred is the immediate ancestor in the tree
            pred = node
            if node.data is not None:
                parent = node
            if addr & (1 << i):
                if update and node.right is None:
                    node.right = TrieNode()
                node = node.right
            else:
                if update and node.left is None:
                    node.left = TrieNode()
                node = node.left
        if node is None:
            assert not update
            return None, parent.data
        else:
            if delete:
                assert not update
                if pred.left is node:
                    pred.left = None
                elif pred.right is node:
                    pred.right = None
                else:
                    assert False
            if update:
                node.data = data
            return node.data, parent.data


class IPNodeData(object):
    __slots__ = ('ip', 'data')

    def __init__(self, ip, data):
        self.ip = ip
        self.data = data

    def __repr__(self):
        return '%s(%s)' % (self.ip, self.data)


class IPTrie(Trie):
    def __init__(self, version):
        if version == 4:
            Trie.__init__(self, 32)
        elif version == 6:
            Trie.__init__(self, 128)
        else:
            raise Exception('Unknown IP version')
        self._version = version

    @property
    def version(self):
        return self._version

    def insert(self, ip, data):
        assert ip.version == self._version
        return Trie.find(self, ip.address, ip.prefix, data=IPNodeData(ip, data), update=True)[1]

    def delete(self, ip):
        assert ip.version == self._version
        Trie.find(self, ip.address, ip.prefix, data=None, update=True)

    def delete_subtree(self, ip):
        Trie.find(self, ip.address, ip.prefix, delete=True)

    def parent(self, ip):
        assert ip.version == self._version
        return Trie.find(self, ip.address, ip.prefix)[1]

    def find(self, ip):
        assert ip.version == self._version
        return Trie.find(self, ip.address, ip.prefix)[0]

    def dump(self):
        lines = []

        def _dump(node, prefix=0):
            if node is None:
                return
            if node.data is not None:
                lines.append(' ' * prefix + str(node.data))
            _dump(node.left, prefix + 1)
            _dump(node.right, prefix + 1)
        _dump(self._root)
        return '\n'.join(lines)
