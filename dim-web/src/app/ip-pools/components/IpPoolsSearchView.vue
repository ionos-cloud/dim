<template>
  <div id="zones-list-search" class="container is-fluid">
    <br>
    <section v-if="pools_count">
      <article class="message is-info is-small">
        <div class="message-body">
          <span v-if="pools_count > 1">
            {{ pools_count }} pools found matching "{{ pattern }}".
          </span>
          <span v-else>
            1 pool found matching "{{ pattern }}".
          </span>
        </div>
      </article>
      <table class="table is-fullwidth is-hoverable">
        <thead>
        <tr v-on:click="toggleOrder" class="pointer">
          <th class="is-narrow">
            <span class="icon is-left is-small">
              <i :class="'fa fa-sort-alpha-' + current_order">
              </i>
            </span>
          </th>
          <th>
            Name
          </th>
          <th>VLAN</th>
          <th>Networks</th>
          <th v-if="can_network_admin"></th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(pool, i) in pools">
          <td>{{ (current_page - 1) * page_size + i + 1 }}</td>
          <td class="pointer">
            <router-link :to="{ name: 'pool', params: {pool_name: pool.name} }">
              {{ pool.name }}
            </router-link>
          </td>
          <td>{{ pool.vlan }}</td>
          <td>
            <ul>
              <li v-for="subnet in pool.subnets">{{ subnet }}</li>
            </ul>
          </td>
          <td class="has-icons-left pointer" v-on:click="removePool(pool)" v-if="can_network_admin">
              <span class="icon is-small is-left is-desktop">
              <i class="fa fa-times"></i>
            </span> remove
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
    <section v-else>
      <article class="message is-warning is-small">
        <div class="message-body">
          No pools found matching "{{ pattern }}".
        </div>
      </article>
    </section>
  </div>
</template>

<script>
  export default {
    name: 'pools-search-view',
    props: ['rights'],
    data () {
      return {
        pools: [],
        pools_count: 0,
        current_offset: 0,
        current_page: 1,
        current_order: 'asc',
        min_page: 1,
        max_page: 1,
        pattern: this.$route.params.pattern,
        page_size: 10
      };
    },
    computed: {
      can_network_admin: function () {
        if (this.rights) {
          return this.rights.indexOf('can_network_admin') !== -1;
        }
      }
    },
    watch: {
      page_size: function () {
        this.getPage(1);
      }
    },
    methods: {
      getPage (page) {
        this.current_page = page;
        this.current_offset = this.page_size * (page - 1);
        this.getPools();
      },
      getPools () {
        let params = {
          offset: this.current_offset,
          limit: this.page_size,
          fields: true,
          order: this.current_order
        };

        const regexIPv4 = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/g;
        const regexIPv6 = /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:)))(%.+)?\s*$/g;

        const foundIPv4 = regexIPv4.exec(this.pattern);
        const foundIPv6 = regexIPv6.exec(this.pattern);

        if (foundIPv4 != null) {
          params.cidr = this.pattern;
          this.jsonRpc('ipblock_get_attrs', [this.pattern], (response) => {
            if (response.data.result) {
              this.pools_count = 1;
              this.max_page = Math.ceil(this.pools_count / this.page_size);
              var poolObject = {};
              poolObject.name = response.data.result.pool;
              poolObject.subnets = [response.data.result.subnet];
              poolObject.vlan = 'N/A';
              this.pools = [poolObject];
            } else {
              this.pools_count = 0;
              this.max_page = 1;
              this.pools = [];
            }
          }, true);
        } else if (foundIPv6 != null) {
          this.jsonRpc('ipblock_get_attrs', [this.pattern], (response) => {
            if (response.data.result) {
              this.pools_count = 1;
              this.max_page = Math.ceil(this.pools_count / this.page_size);
              var poolObject = {};
              poolObject.name = response.data.result.pool;
              poolObject.subnets = [response.data.result.subnet];
              poolObject.vlan = 'N/A';
              this.pools = [poolObject];
            } else {
              this.pools_count = 0;
              this.max_page = 1;
              this.pools = [];
            }
          }, true);
        } else {
          if (this.pattern.indexOf(':') !== -1 || this.pattern.indexOf('.') !== -1) {
            params.cidr = this.pattern;
          } else {
            params.pool = '*' + this.pattern + '*';
          }
          this.jsonRpc('ippool_list2', [params], (response) => {
            if (response.data.result) {
              this.pools_count = response.data.result.count;
              this.max_page = Math.ceil(this.pools_count / this.page_size);
              this.pools = response.data.result.data;
            } else {
              this.pools_count = 0;
              this.max_page = 1;
              this.pools = [];
            }
          }, true);
        }
      },
      toggleOrder () {
        this.current_order = this.current_order === 'asc' ? 'desc' : 'asc';
        this.getPage(this.current_page);
      },
      searchPools (pattern) {
        if (pattern === '') {
          this.$router.push({name: 'pools-list'});
        } else {
          this.$router.push({name: 'pools-search', params: {pattern: pattern}});
          this.pattern = pattern;
          this.getPage(1);
        }
      },
      removePool (pool) {
        this.$eventBus.$emit('open_modal', 'ip_pool_remove', pool);
      },
      reloadPools () {
        this.searchPools(this.pattern);
      }
    },
    mounted () {
      this.$eventBus.$on('reload_ip_pools', this.reloadPools);
      this.getPage(1);
      this.$eventBus.$on('search', this.searchPools);
    },
    beforeDestroy () {
      this.$eventBus.$emit('empty_search');
    }
  };
</script>
