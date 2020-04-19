from dimcli.cliparse import Command, Option, Group, Argument, Token
from unittest import TestCase


class T1(TestCase):
    def setUp(self):
        self.c = Command(
            'ndcli',
            Option('D', 'detailed',
                   help='detailed return codes'),
            Option('s', 'server',
                   help='Dim server URL',
                   action='store'),
            Command('set',
                    Group(Argument('field', choices=('master', 'mail', 'export_file'), action='append_unique'),
                          Argument('value', action='append'),
                          nargs='*')))

    def test1(self):
        p = self.c.parse(('set', '-D', 'mail', '1', 'export_file', '2'))
        print(p.errors)
        assert not p.errors
        assert p.subcommands == ['set']
        assert p.values == {'detailed': True,
                            'field': ['mail', 'export_file'],
                            'value': ['1', '2'],
                            'server': None}

    def test2(self):
        p = self.c.parse(('set', '-D', 'mail', '1', 'export_file'))
        assert p.errors == ['A value is required for VALUE']

    def test3(self):
        p = self.c.parse(('-f',))
        assert p.errors[0] == 'Unknown option -f'


class T2(TestCase):
    def setUp(self):
        self.c = Command('ndcli',
                         Command('create',
                                 Command('pool',
                                         Argument('poolname'),
                                         Group(Token('vlan'),
                                               Argument('vlan'),
                                               nargs='?'),
                                         Argument('attrs', metavar='KEY:VALUE', nargs='*'))))

    def test1(self):
        p = self.c.parse(('create', 'pool', 'test'))
        assert not p.errors
        assert p.values == dict(poolname='test',
                                vlan=None,
                                attrs=[])

    def test2(self):
        p = self.c.parse(('create', 'pool', 'test', 'vlan', '2'))
        assert not p.errors
        assert p.values == dict(poolname='test',
                                vlan='2',
                                attrs=[])

    def test3(self):
        p = self.c.parse(('create', 'pool', 'test', 'vlan', '2', 'g:g', 'f:f'))
        assert not p.errors
        assert p.values == {'poolname': 'test', 'vlan': '2', 'attrs': ['g:g', 'f:f']}


class Simple(TestCase):
    def test_qual(self):
        c = Command('ndcli',
                    Argument('1', choices=('a', 'b'), nargs='?'),
                    Argument('2'),
                    Argument('3', choices=('c', 'd'), nargs='*'),
                    Argument('4', choices=('e', 'f')),
                    Argument('5', nargs='*'))

        assert c.parse(('xxxx', 'c', 'd', 'e', 'extra')).values == \
            {'1': None,
             '2': 'xxxx',
             '3': ['c', 'd'],
             '4': 'e',
             '5': ['extra']}

        assert c.parse(('x', 'f')).values == {'1': None,
                                              '2': 'x',
                                              '3': [],
                                              '4': 'f',
                                              '5': []}

    def test_groups(self):
        c = Command('ndcli',
                    Group(Token('ttl'),
                          Argument('ttl'),
                          nargs='?'),
                    Command('test'))

        assert c.parse(('ttl', '10', 'test')).values == {'ttl': '10'}
        assert c.parse(('test',)).values == {'ttl': None}
        assert c.parse(('bbl', '10', 'test')).errors
        assert c.parse(('ttl', '10')).errors

    def test_completion(self):
        def completions(line):
            return c.complete(line, len(line))
        c = Command('ndcli',
                    Option('D', 'detailed'),
                    Option('q', 'quiet'),
                    Command('create',
                            Command('pool',
                                    Argument('poolname'),
                                    Option('p', 'perfect'),
                                    Group(Token('vlan'),
                                          Argument('vlan'),
                                          nargs='?'),
                                    Command('a'))))
        assert completions('ndcli ') == set(['create'])
        assert completions('ndcli -') == set(['--detailed', '-D', '--quiet', '-q'])
        assert completions('prog -- -') == set()
        assert completions('prog create ') == set(['pool'])
        assert completions('prog create pool ') == set()
        assert completions('prog create pool -') == set(['--detailed', '-D', '--quiet', '-q', '--perfect', '-p'])
        assert completions('prog create pool test ') == set(['vlan', 'a'])
        assert completions('prog create pool test vlan ') == set()
        assert completions('prog create pool test vlan 1 ') == set(['a'])


def test_completion2():
    def completions(line):
        return c.complete(line, len(line))
    c = Command('ndcli',
                Group(Argument('field', choices=('f1', 'f2', 'f3'), action='append_unique'),
                      Argument('value', action='append'),
                      nargs='*'))
    assert completions('ndcli ') == set(['f1', 'f2', 'f3'])
    assert completions('ndcli f1 ') == set()
    assert completions('ndcli f1 1 ') == set(['f2', 'f3'])
    assert completions('ndcli f1 1 f') == set(['f2', 'f3'])
    assert completions('ndcli f1 1 f2 2 ') == set(['f3'])


def test_completion_quoted():
    def completions(line):
        return c.complete(line, len(line))
    c = Command('ndcli', Group(Argument('field', choices=('a b', 'a!$\\'), action='append_unique')))
    assert completions('ndcli ') == set(['a\ b', 'a\'!\'\$\\\\'])
    assert completions("ndcli 'a") == set(["'a b'", "'a!$\\'"])
    assert completions('ndcli "a') == set(['"a b"', '"a"\'!\'"\$\\\\"'])
    assert completions('ndcli a\ ') == set(['a\\ b'])


def test_subcommand_case():
    def completions(line):
        return c.complete(line, len(line))
    c = Command('ndcli',
                Command('test'))
    assert not c.parse(['test']).errors
    assert not c.parse(['TeSt']).errors
    assert c.parse(['best']).errors


def test_default_subcommand():
    c = Command('ndcli',
                Command('sub1', Argument('food'), Option('', 'drink'), defaults={'run': 'sub1'}),
                Command('sub2', defaults={'run': 'sub2'}),
                default_subcommand='sub1')
    assert c.parse([]).values == {'run': 'sub1', 'food': None, 'drink': None}
    assert c.parse(['sub1']).values.run == 'sub1'
    assert c.parse(['sub2']).values.run == 'sub2'


def test_star_star():
    c = Command('ndcli',
                Group(Argument('fields', choices=['a', 'b'], action='append_unique'), Argument('values', action='append'), nargs='*'),
                Argument('second', nargs='*'))
    assert c.parse(['a', '1', '2', '3']).values == {'fields': ['a'], 'values': ['1'], 'second': ['2', '3']}
    assert c.parse(['a', '1', 'b', 'c', '2', '3']).values == {'fields': ['a', 'b'], 'second': ['2', '3'], 'values': ['1', 'c']}
    assert c.parse([]).values == {'fields': [], 'second': [], 'values': []}


def test_plus():
    c = Command('ndcli',
                Group(Token('val'), Argument('val', action='append'), nargs='+'),
                Group(Token('endval'), Argument('endval'), nargs='?'))
    assert c.parse([]).errors
    assert c.parse(['endval', 'a']).errors
    assert c.parse(['val', 'a']).values == {'val': ['a'], 'endval': None}
    assert c.parse(['val', 'a', 'val', 'b']).values == {'val': ['a', 'b'], 'endval': None}
    assert c.parse(['val', 'a', 'val', 'b', 'endval', 'c']).values == {'val': ['a', 'b'], 'endval': 'c'}


def test_ambiguity():
    c = Command('ndcli',
                Argument('var', nargs='*', stop_at='end'),
                Group(Token('end'), Argument('endval'), nargs='?'))
    assert c.parse(['a']).values == {'var': ['a'], 'endval': None}
    assert c.parse(['a', 'end', '1']).values == {'var': ['a'], 'endval': '1'}
    assert c.parse('a end b end c'.split()).values == {'var': ['a', 'end', 'b'], 'endval': 'c'}


def test_plus_options():
    c = Command('ndcli',
                Option('q', 'quiet'),
                Command('sub',
                        Argument('var', nargs='+', stop_at='end')))
    assert c.parse(['sub', 'a']).values == {'var': ['a'], 'quiet': None}
    assert c.parse(['sub', 'a', '-q']).values == {'var': ['a'], 'quiet': True}
