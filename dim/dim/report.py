import re

from flask import current_app, g, Blueprint
import click
from typing import Optional

import dim.commands
import dim.ipaddr


dim_report = Blueprint('dim_report', __name__, cli_group='report')


@dim_report.cli.command('pool')
@click.argument('pools')
@click.option(
    '--warning',
    type=int,
    help='''The minimum number of days which are required to fill the pool. Everything
                       higher than this number will cause the respective pool to be omitted from the
                       report. If not specified, data for all the pools will be printed.''',
)
@click.option(
    '--estimate',
    type=int,
    default=30,
    help='''The number of days in the past used to estimate the rate of address
                       usage. The default value is 30.''',
)
@click.option(
    '--template',
    help='''The template file to be used for formatting the report. The default is
                       /etc/dim/pool_report.template''',
)
def pool_report(
    pools: str,
    warning: Optional[int] = None,
    estimate: int = 30,
    template: Optional[str] = None,
):
    '''Prints a pool usage report for a comma-separated list of pool names.
    A suffix (ex: /56) can be added to pool names to show block counts instead of IP counts.'''
    try:
        pool_list = []
        for pool_str in pools.split(','):
            if not pool_str:
                continue
            prefix = None
            sp = pool_str.split('/')
            if len(sp) == 1:
                pool_name = sp[0]
            elif len(sp) == 2:
                pool_name, prefix = sp
                prefix = int(prefix)
            else:
                raise Exception("Wrong format for pool: %r" % pool_str)
            pool_list.append((pool_name, prefix))
    except Exception as e:
        print(str(e))
        return
    for pool, prefix in pool_list:
        pr = dim.commands.pool_report(
            pool,
            prefix=prefix,
            estimate=estimate,
            warning_threshold=warning,
            template=template,
        )
        if pr:
            print(pr)


@dim_report.cli.command('usage')
@click.option(
    '--hosting_pools',
    required=True,
    help='A perl regular expression for matching hosting pool names.',
)
@click.option('--arin', required=True, help='A comma-separated list of ARIN nets.')
@click.option('--ripe', required=True, help='A comma-separated list of RIPE nets.')
@click.option(
    '--ignored',
    help='''By default, a warning is issued for every subnet not included in either --arin
                       or --ripe, but present in a pool. This option is a comma-separated list of nets
                       which can be safely excluded from the report.''',
)
def usage_report(pool_regexp: str, arin: str, ripe: str, ignored: Optional[str] = None):
    '''Prints IP usage reports'''

    def block_list(block_str_list):
        return [dim.ipaddr.IP(b) for b in block_str_list]

    try:
        hosting_pools = re.compile(hosting_pools)
        arin = block_list(arin.split(','))
        ripe = block_list(ripe.split(','))
        ignored = block_list(ignored.split(',')) if ignored else []
    except Exception as e:
        print(str(e))
        return
    print("Global #####################")
    print(dim.commands.usage_report(pool_regexp, arin + ripe, ignored, warn=False))
    print("\n\nUS #########################")
    print(dim.commands.usage_report(pool_regexp, arin, ignored, warn=False))
    print("\n\nEU #########################")
    print(dim.commands.usage_report(pool_regexp, ripe, ignored, warn=False))


@dim_report.cli.command('update_history')
def update_history():
    '''Updates the allocationhistory table with pool usage data'''
    dim.commands.update_history()
