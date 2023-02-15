import os.path

from flask import current_app as app
from typing import Optional

from dim.models import UserType, Ipblock, Pool, AllocationHistory, Layer3Domain
from dim.rpc import get_user
from dim.transaction import time_function, transaction
from math import floor, ceil
from dim import db


def get_user_type(user_type_str: str) -> UserType:
    user_type = UserType.query.filter_by(name=user_type_str).first()
    if user_type is None:
        raise Exception("User type '%s' does not exist" % user_type_str)
    return user_type


@time_function
@transaction
def rebuild_tree():
    for layer3domain in Layer3Domain.query.all():
        Ipblock.build_tree_parents(layer3domain, 4)
        Ipblock.build_tree_parents(layer3domain, 6)


@time_function
@transaction
def set_user(username: str, user_type_str: str):
    if user_type_str not in ('User', 'Admin'):
        raise ValueError("User type must be either 'User' or 'Admin'")

    user = get_user(username)
    user.user_type = get_user_type(user_type_str)


@time_function
@transaction
def delete_user(username: str):
    user = get_user(username)
    db.session.delete(user)


@time_function
@transaction
def update_history():
    # We don't hold a lock and hope no pools are deleted until the transaction
    # is commited
    AllocationHistory.collect_data()


def read_etc_file(filename: str):
    try:
        return open(os.path.join(app.config.root_path, '..', 'etc', filename)).read()
    except:
        return open('/etc/dim/' + filename).read()


@time_function
def pool_report(pool_name: str, prefix: Optional[int] = None, estimate: int = 30, warning_threshold: Optional[int] = None, template: Optional[str] = None):
    try:
        if template is not None:
            template_string = open(template).read()
        else:
            template_string = read_etc_file('pool_report.template')
    except Exception as e:
        return "Missing template: " + str(e)

    pool: Optional[Pool] = Pool.query.filter_by(name=pool_name).first()
    if not pool:
        return "WARNING: Pool %s does not exist." % pool_name
    total_bits = 32 if pool.version == 4 else 128
    if prefix is None:
        prefix = total_bits
        objects = "IPs"
    else:
        objects = "/%d blocks" % prefix
    block_size: int = 2 ** (total_bits - prefix)
    current_used = pool.used_ips
    current_free = pool.total_ips - current_used
    history_days = (1, 7, 30)

    # Get prediction
    ahf = pool.allocation_history(estimate)
    if ahf:
        usage_per_day = float(current_used - ahf.used_ips) / estimate
        if usage_per_day > 0:
            days_until_full = current_free / usage_per_day
            if warning_threshold and days_until_full > warning_threshold:
                return
            days_until_full_str = '{0:.1f}'.format(days_until_full)
        else:
            days_until_full_str = 'infinity'
            if warning_threshold:
                return
        prediction = ("Based on data from the last {0} days, the pool will be full in {1} days.")\
            .format(estimate, days_until_full_str)
    else:
        if warning_threshold:
            return
        prediction = "Data from {0} days ago not available.".format(estimate)

    # Return report
    def normalize(nr) -> float:
        return float(nr) / block_size
    usage = [ceil(normalize(current_used - ah.used_ips)) if ah else 'n/a'
             for ah in [pool.allocation_history(days) for days in history_days]]
    keys = dict(pool_name=pool_name,
                current_free=floor(normalize(current_free)),
                objects=objects,
                prediction=prediction)
    for i in range(len(history_days)):
        keys['interval_' + str(i + 1)] = history_days[i]
        keys['usage_' + str(i + 1)] = usage[i]
    try:
        return template_string.format(**keys)
    except Exception as e:
        return "Template error: %s" % e


@time_function
def usage_report(hosting_pools, networks, ignored, warn):
    subnet_total = sum(net.numhosts for net in networks)
    subnet_used = used_hosting = wasted_hosting = used_other = wasted_other = 0
    warnings = []
    for pool in Pool.query.all():
        if pool.version != 4:
            continue
        used = free = 0
        for subnet in pool.subnets:
            if any(subnet.ip in n for n in networks):
                used += subnet.used
                free += subnet.free
            elif warn:
                warnings.append("WARNING: {0} from pool {1} not included".format(subnet, pool.name))
        subnet_used += used + free
        if hosting_pools.search(pool.name):
            used_hosting += used
            wasted_hosting += free
        else:
            used_other += used
            wasted_other += free

    def split_view(header_a, a, header_b, b):
        def percentage(a, b):
            return float(a) * 100 / b if b else 0
        return "{ha}: {a} ({pa:.2f}%) {hb}: {b} ({pb:.2f}%)".format(
            ha=header_a, a=a, hb=header_b, b=b,
            pa=percentage(a, a + b),
            pb=percentage(b, a + b))

    return "\n".join(
        ["Calculating: " + ", ".join(str(n) for n in networks)] + warnings +
        ["",
         split_view('Used IPs Hosting', used_hosting,
                    'used other', used_other),
         split_view('Wasted IPs Hosting', wasted_hosting,
                    'wasted other', wasted_other),
         split_view('SUM IPs Hosting', used_hosting + wasted_hosting,
                    'SUM other', used_other + wasted_other),
         "",
         "Subnet space available: {0}".format(subnet_total),
         "Subnet space used: {0}".format(subnet_used),
         "Subnet space free: {0}".format(subnet_total - subnet_used)])
