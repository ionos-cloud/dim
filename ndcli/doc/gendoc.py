import sys
import os
# use path relative to doc/gendoc.py (this file)
# to find its corresponding dimcli module
ndcli_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ndcli_path)
from dimcli import cmd


def options(opt_list):
    for opt in opt_list:
        opt_str = []
        if opt.short:
            opt_str.append('-' + opt.short)
        if opt.long:
            opt_str.append('--' + opt.long)
        yield ', '.join(opt_str), opt.help


def print_options(opt_list):
    for name, help in options(opt_list):
        print('%-23s' % name, help)


def command_leaves(cmd):
    if cmd.subcommands:
        for sub in sorted(cmd.subcommands, key=lambda s: s.name):
            for leaf, chain in command_leaves(sub):
                yield leaf, [cmd] + chain
    else:
        yield cmd, [cmd]


def gendoc():
    print("Global Options\n==============\n")
    print_options(cmd.options)

    print("\nCommands\n========\n")
    for leaf, chain in command_leaves(cmd):
        usage = cmd.chain_usage(chain)
        print(usage)
        print('-' * len(usage))
        if leaf.description or leaf.help:
            print("\n", leaf.description or leaf.help)
        options = sum([c.options for c in chain[1:]], [])
        if options:
            print("\nOptions:\n")
            print_options(options)
        print()

gendoc()
