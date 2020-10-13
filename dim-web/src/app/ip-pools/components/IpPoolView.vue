<template>
  <div id="ip-pool-view" class="container is-fluid">
    <section class="hero">
      <div class="hero-body">
        <div>
          <h1 class="title">{{ pool }}
            <span class="icon is-large is-right has-text-warning">
            <i class="fa fa-star" v-if="this.is_favorite" v-on:click="removeFromFavorites"></i>
            <i class="fa fa-star-o" v-else v-on:click="addToFavorites"></i>
          </span>
          </h1>
          <h2 class="subtitle">
            <span v-show="vlan">VLAN {{ vlan }}</span>
            <span class="field is-grouped is-pulled-right">
              <span class="control">
                <button class="button is-link" v-on:click="addSubnet" v-if="can_network_admin">Add subnet</button>
              </span>
              <span class="control">
                <button class="button is-link" v-on:click="addDelegation" v-if="can_network_admin">Add delegation</button>
              </span>
            </span>
          </h2>
        </div>
      </div>
    </section>
    <div class="tabs">
      <ul>
        <li :class="{'is-active': current_tab === 'all'}" v-if="version === 4">
        <a v-on:click="getTab('all')">All IPs</a>
        </li>
        <li :class="{'is-active': current_tab === 'free'}">
          <a v-on:click="getTab('free')">Free IPs</a>
        </li>
        <li :class="{'is-active': current_tab === 'used'}">
          <a v-on:click="getTab('used')">Used IPs</a>
        </li>
        <li :class="{'is-active': current_tab === 'available'}">
          <a v-on:click="getTab('available')">Availability</a>
        </li>
      </ul>
    </div>
    <section v-if="ips_count && current_tab !== 'available'">
      <article class="message is-info is-small">
        <div class="message-body">
          <span v-if="ips_count > 1">
            {{ ips_count }} {{ current_tab === 'all'? '' : current_tab }} IPs found.
          </span>
          <span v-else>
            1 {{ current_tab }} IP found.
          </span>
        </div>
      </article>
      <table class="table is-fullwidth" :class="{'is-hoverable': current_tab !== 'all'}">
        <thead>
        <tr>
          <th>IP</th>
          <th v-if="current_tab !== 'free'">PTR</th>
          <th v-if="current_tab !== 'free'">Modified (UTC)</th>
          <th v-if="current_tab !== 'free'">User</th>
          <th v-if="current_tab !== 'free'">Comment</th>
          <th v-if="can_allocate"></th>
          <th v-if="current_tab !== 'free' && can_allocate"></th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(ip, i) in ips" :class="ipColorClass(ip)">
          <td>{{ ip.ip }}</td>

          <td v-if="current_tab !== 'free'">{{ ip.ptr_target }}</td>
          <td v-if="current_tab !== 'free'">{{ ip.modified | formatDate  }}</td>
          <td v-if="current_tab !== 'free'">{{ ip.modified_by }}</td>
          <td v-if="current_tab !== 'free'">{{ ip.comment }}</td>
          <td v-if="can_allocate">

            <span v-if="ip.status === 'Available'" v-on:click="reserveIP(ip.ip)">
              <span class="icon is-small is-left is-desktop">
                <i class="fa fa-plus"></i>
              </span>
              reserve
            </span>

            <span v-else  v-on:click="editIP(ip.ip)">
              <span class="icon is-small is-left is-desktop">
                <i class="fa fa-pencil"></i>
              </span>edit
            </span>
          </td>
          <td v-if="current_tab !== 'free' && can_allocate">
            <span v-if="ip.status === 'Static'"  v-on:click="freeIP(ip.ip)">
              <span class="icon is-small is-left is-desktop">
                <i class="fa fa-times"></i>
              </span>
              free
            </span>
          </td>
        </tr>
        </tbody>
      </table>
      <nav class="pagination is-centered" role="navigation" aria-label="pagination">
        <ul class="pagination-list">
          <li v-if="min_page < current_page" v-on:click="getPage(min_page)">
            <a class="pagination-link">{{ min_page }}</a>
          </li>
          <li v-if="min_page < current_page - 2">
            <span class="pagination-ellipsis">&hellip;</span>
          </li>
          <li v-if="min_page < current_page -1" v-on:click="getPage(current_page - 1)">
            <a class="pagination-link">{{ current_page - 1}}</a>
          </li>
          <li>
            <a class="pagination-link is-current">{{ current_page }}</a>
          </li>
          <li v-if="current_page + 1 < max_page" v-on:click="getPage(current_page + 1)">
            <a class="pagination-link">{{ current_page + 1}}</a>
          </li>
          <li v-if="current_page + 2 < max_page">
            <span class="pagination-ellipsis">&hellip;</span>
          </li>
          <li v-if="current_page < max_page" v-on:click="getPage(max_page)">
            <a class="pagination-link">{{ max_page }}</a>
          </li>
        </ul>
        <span class="select pagination-size">
          <select v-model="page_size">
            <option v-for="size in $config.PAGE_SIZES" :value="size">
              {{ size }}
            </option>
          </select>
        </span>
      </nav>
    </section>
    <section v-if="ips_count === 0 && current_tab !== 'available'">
      <article class="message is-warning is-small">
        <div class="message-body">
          No {{ current_tab === 'all'? '' : current_tab }} IPs found.
        </div>
      </article>
    </section>
    <section v-if="current_tab === 'available'">
      <table class="table is-fullwidth is-hoverable" v-if="subnets_total">
        <thead>
        <tr>
          <th>Subnet</th>
          <th>Priority</th>
          <th>All IPs</th>
          <th>Used IPs</th>
          <th>Free IPs</th>
          <th>Availability</th>
          <th v-if="can_network_admin"></th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(subnet, i) in subnets">
          <td>{{ subnet.subnet }}</td>
          <td>{{ subnet.priority }}</td>
          <td>{{ subnet.total }}</td>
          <td>{{ subnet.total - subnet.free }} ({{ 100 - getPercentage(subnet.free, subnet.total)}}%)</td>
          <td>{{ subnet.free }} ({{ getPercentage(subnet.free, subnet.total)}}%)</td>
          <td>
            <progress class="progress"
                      :class="{'is-danger': getPercentage(subnet.free, subnet.total) <= 25,
                      'is-warning': getPercentage(subnet.free, subnet.total) <= 75,
                      'is-success': getPercentage(subnet.free, subnet.total) <= 100}"
                      :value="subnet.total - subnet.free"
                      :max="subnet.total"></progress>
          </td>
          <td v-if="can_network_admin" v-on:click="removeSubnet(subnet.subnet)" class="pointer">
            <span class="icon is-small is-left is-desktop">
              <i class="fa fa-times"></i>
            </span>
            remove
          </td>
        </tr>
        <tr v-if="subnets.length > 1" class="is-selected">
          <td>Pool totals</td>
          <td></td>
          <td></td>
          <td>{{ subnets_total }}</td>
          <td>{{ subnets_total - subnets_free }} ({{ 100 - getPercentage(subnets_free, subnets_total) }}%)</td>
          <td>{{ subnets_free }} ({{ getPercentage(subnets_free, subnets_total) }}%)</td>
          <td>
            <progress class="progress"
                      :class="{'is-danger': getPercentage(subnets_free, subnets_total) <=25,
                      'is-warning': getPercentage(subnets_free, subnets_total) <=75,
                      'is-success': getPercentage(subnets_free, subnets_total) <= 100}"
                      :value="subnets_total - subnets_free"
                      :max="subnets_total"></progress>
          </td>
          <td v-if="can_network_admin"></td>
        </tr>
        </tbody>
      </table>
      <table class="table is-fullwidth is-hoverable" v-if="delegations_total">
        <thead>
        <tr>
          <th>Delegation</th>
          <th>All IPs</th>
          <th>Used IPs</th>
          <th>Free IPs</th>
          <th>Availability</th>
          <th v-if="can_network_admin"></th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(delegation, i) in delegations">
          <td>{{ delegation.delegation }}</td>
          <td>{{ delegation.total }}</td>
          <td>{{ delegation.total - delegation.free }} ({{ 100 - getPercentage(delegation.free, delegation.total)}}%)</td>
          <td>{{ delegation.free }} ({{ getPercentage(delegation.free, delegation.total)}}%)</td>
          <td>
            <progress class="progress"
                      :class="{'is-danger': getPercentage(delegation.free, delegation.total) <= 25,
                      'is-warning': getPercentage(delegation.free, delegation.total) <= 75,
                      'is-success': getPercentage(delegation.free, delegation.total) <= 100}"
                      :value="delegation.total - delegation.free"
                      :max="delegation.total"></progress>
          </td>
          <td v-if="can_network_admin" v-on:click="removeSubnet(delegation.subnet)" class="pointer">
            <span class="icon is-small is-left is-desktop">
              <i class="fa fa-times"></i>
            </span>
            remove
          </td>
        </tr>
        <tr v-if="delegations.length > 1" class="is-selected">
          <td>Delegation totals</td>
          <td></td>
          <td>{{ delegations_total }}</td>
          <td>{{ delegations_total - delegations_free }} ({{ 100 - getPercentage(delegations_free, delegations_total) }}%)</td>
          <td>{{ delegations_free }} ({{ getPercentage(delegations_free, delegations_total) }}%)</td>
          <td>
            <progress class="progress"
                      :class="{'is-danger': getPercentage(delegations_free, delegations_total) <=25,
                      'is-warning': getPercentage(delegations_free, delegations_total) <=75,
                      'is-success': getPercentage(delegations_free, delegations_total) <= 100}"
                      :value="delegations_total - delegations_free"
                      :max="delegations_total"></progress>
          </td>
          <td v-if="can_network_admin"></td>
        </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>
<script>
  export default {
    name: 'ip-pool-view',
    props: ['rights'],
    data () {
      return {
        pool: this.$route.params.pool_name,
        is_favorite: false,
        vlan: null,
        can_allocate: false,
        ips_count: 0,
        ips: [],
        subnets: [],
        subnets_total: 0,
        subnets_free: 0,
        delegations: [],
        delegations_total: 0,
        delegations_free: 0,
        version: 6,
        current_tab: 'all',
        current_page: 1,
        min_page: 1,
        max_page: 1,
        mapping: {
          'all': this.getAllIPs,
          'free': this.getFreeIPs,
          'used': this.getUsedIPs,
          'available': this.getAvailability
        },
        page_size: 10
      };
    },
    watch: {
      page_size: function () {
        this.getPage(1);
      }
    },
    computed: {
      can_network_admin: function () {
        if (this.rights) {
          return this.rights.indexOf('can_network_admin') !== -1;
        }
      }
    },
    methods: {
      getPercentage (fraction, total) {
        return Math.floor((fraction / total) * 100);
      },
      getTab (tab) {
        this.current_tab = tab;
        this.current_order = 'asc';
        this.ips_count = 0;
        this.ips = [];
        this.getPage(1);
      },
      getPage (page) {
        this.mapping[this.current_tab](page);
      },
      ipColorClass (ip) {
        if (this.current_tab !== 'all' || this.version === 6) {
          return '';
        }
        if (ip.delegation) {
          return 'success-table-row';
        }
        if (ip.status !== 'Available') {
          return 'danger-table-row';
        }
        return '';
      },
      getAllIPs (page) {
        let attributes = ['ip', 'domain', 'modified', 'modified_by', 'comment', 'pool', 'ptr_target', 'delegation', 'version'];
        this.getIPs(page, attributes);
      },
      getFreeIPs (page) {
        let attributes = ['ip', 'pool'];
        this.getIPs(page, attributes);
      },
      getUsedIPs (page) {
        let attributes = ['ip', 'domain', 'modified', 'modified_by', 'comment', 'pool', 'ptr_target'];
        this.getIPs(page, attributes);
      },
      getIPs (page, attributes) {
        let params = [{
          limit: this.page_size,
          type: this.current_tab,
          attributes: attributes,
          pool: this.$route.params.pool_name,
          layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
        }];
        if (this.ips.length > 0) {
          if (page === this.current_page + 1) {
            params[0].after = this.ips[this.ips.length - 1].ip;
          } else {
            params[0].offset = this.page_size * (page - 1);
          }
        }
        this.jsonRpc('ip_list2', params, (response) => {
          if (response.data.result) {
            this.ips_count = response.data.result.count;
            this.max_page = Math.ceil(this.ips_count / this.page_size);
            this.ips = response.data.result.data;
            this.current_page = page;
          }
        }, true);
      },
      getAllPools (page) {
        this.getPools({}, page);
      },
      getAvailability (page) {
        this.ips = [];
        this.ips_count = 0;
        this.subnets = [];
        this.subnets_total = 0;
        this.subnets_free = 0;
        let params = [
          this.$route.params.pool_name
        ];
        this.jsonRpc('ippool_get_subnets', params, (response) => {
          if (response.data.result) {
            this.subnets = response.data.result;
            for (let i = 0; i < this.subnets.length; i++) {
              this.subnets_total += this.subnets[i].total;
              this.subnets_free += this.subnets[i].free;
            }
          }
        }, true);

        this.delegations = [];
        this.delegations_total = 0;
        this.delegations_free = 0;
        this.jsonRpc('ippool_get_delegations', params, (response) => {
          if (response.data.result) {
            this.delegations = response.data.result;
            for (let i = 0; i < this.delegations.length; i++) {
              this.delegations_total += this.delegations[i].total;
              this.delegations_free += this.delegations[i].free;
            }
          }
        }, true);
      },
      getFavorite () {
        let params = [
          this.pool
        ];
        this.jsonRpc('ippool_favorite', params, (response) => {
          if (response.data.result !== undefined) {
            this.is_favorite = response.data.result;
          }
        });
      },
      getRights () {
        let params = [{
          pool: this.pool,
          can_allocate: true
        }];
        this.jsonRpc('ippool_list2', params, (response) => {
          if (response.data.result.data !== undefined) {
            this.can_allocate = response.data.result.data.length > 0;
          }
        });
      },
      getVLAN () {
        let params = [{
          pool: this.pool
        }];
        this.jsonRpc('ippool_list2', params, (response) => {
          if (response.data.result.data !== undefined) {
            let pool = response.data.result.data[0];
            if (pool) {
              this.vlan = pool.vlan;
              this.version = pool.version;
              this.current_tab = this.version === 4 ? 'all' : 'free';
              this.getTab(this.current_tab);
            }
          }
        });
      },
      addToFavorites () {
        let params = [
          this.pool
        ];
        this.jsonRpc('ippool_favorite_add', params, (response) => {
          this.is_favorite = true;
        });
      },
      removeFromFavorites () {
        let params = [
          this.pool
        ];
        this.jsonRpc('ippool_favorite_remove', params, (response) => {
          this.is_favorite = false;
        });
      },
      reserveIP (ip) {
        this.$eventBus.$emit('open_modal', 'ip_reserve', ip);
      },
      freeIP (ip) {
        this.$eventBus.$emit('open_modal', 'ip_free', ip);
      },
      editIP (ip) {
        this.$eventBus.$emit('open_modal', 'ip_edit', ip);
      },
      refreshList () {
        this.getPage(this.current_page);
      },
      addSubnet () {
        this.$eventBus.$emit('open_modal', 'subnet_add', {pool: {name: this.pool}});
      },
      addDelegation () {
        this.$eventBus.$emit('open_modal', 'delegation_add', {pool: {name: this.pool}, options: []});
      },
      removeSubnet (cidr) {
        this.$eventBus.$emit('open_modal', 'ipblock_remove', cidr);
      }
    },
    mounted () {
      this.$eventBus.$emit('hide_search');
      this.$eventBus.$on('refresh_ips', this.refreshList);
      this.getFavorite();
      this.getVLAN();
      this.getRights();
    },
    beforeDestroy () {
      this.$eventBus.$emit('show_search');
    }
  };
</script>
