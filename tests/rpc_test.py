from tests.util import RPCTest


class IpblockTest(RPCTest):
    def test_function_classification(self):
        unmarked = []
        for name in [n for n in dir(self.r.obj) if not n.startswith('_')]:
            f = getattr(self.r.obj, name)
            if callable(f) and not hasattr(f, 'readonly'):
                unmarked.append(name)
        assert not unmarked
