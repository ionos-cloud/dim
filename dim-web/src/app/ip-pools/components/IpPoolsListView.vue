<template>
  <div id="ip-pools-list-view" class="container is-fluid">
    <div class="tabs">
      <ul>
        <li :class="{'is-active': current_tab === 'favorite'}">
          <a v-on:click="getTab('favorite')">Favorite Pools</a>
        </li>
        <li :class="{'is-active': current_tab === 'edit'}">
          <a v-on:click="getTab('edit')">My Pools</a>
        </li>
        <li :class="{'is-active': current_tab === 'all'}">
          <a v-on:click="getTab('all')">All Pools</a>
        </li>
      </ul>
    </div>
    <section v-if="pools_count">
      <article class="message is-info is-small">
        <div class="message-body">
          <span v-if="pools_count > 1">
            {{ pools_count }} pools found.
          </span>
          <span v-else>
            1 pool found.
          </span>
        </div>
      </article>
    </section>
    <section v-else>
      <article class="message is-warning is-small">
        <div class="message-body">
          No corresponding pools found.
        </div>
      </article>
    </section>
    <section v-if="pools_count">
      <br>
      <button class="button is-link" v-on:click="addPool" v-if="can_network_admin && current_tab === 'edit'">Add pool</button>
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
          <th v-if="can_network_admin && current_tab === 'edit'"></th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(pool, i) in pools">
          <td>{{ (current_page - 1) * page_size + i + 1 }}</td>
          <td>
            <router-link :to="{ name: 'pool', params: {pool_name: pool.name} }" class="pointer">
              {{ pool.name }}
            </router-link>
          </td>
          <td>{{ pool.vlan }}</td>
          <td>
            <ul>
              <li v-for="subnet in pool.subnets">{{ subnet }}</li>
            </ul>
          </td>
          <td class="has-icons-left pointer" v-on:click="removePool(pool)" v-if="can_network_admin && current_tab === 'edit'">
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
  </div>
</template>
<script>
  export default {
    name: 'ip-pools-list-view',
    props: ['rights'],
    data () {
      return {
        pools_count: 0,
        pools: [],
        current_tab: 'favorite',
        current_offset: 0,
        current_page: 1,
        current_order: 'asc',
        min_page: 1,
        max_page: 1,
        mapping: {
          'edit': this.getEditablePools,
          'all': this.getAllPools,
          'favorite': this.getFavoritePools
        },
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
      '$route.hash' (newValue, oldValue) {
        if (newValue) {
          this.current_tab = this.$route.hash.substring(1);
        }
        this.current_order = 'asc';
        this.pools_count = 0;
        this.pools = [];
        this.getPage(1);
      },
      page_size: function () {
        this.getPage(1);
      }
    },
    methods: {
      getTab (tab) {
        if (tab !== 'favorite' || this.$route.hash) {
          this.$router.push(this.$route.path + '#' + tab);
        }
      },
      getPage (page) {
        this.current_offset = this.page_size * (page - 1);
        this.mapping[this.current_tab](page);
      },
      getPools (extra, page) {
        let params = [{
          offset: this.current_offset,
          limit: this.page_size,
          fields: true,
          order: this.current_order,
          ...extra
        }];
        this.jsonRpc('ippool_list2', params, (response) => {
          if (response.data.result) {
            this.pools_count = response.data.result.count;
            this.max_page = Math.ceil(this.pools_count / this.page_size);
            this.pools = response.data.result.data;
            this.current_page = page;
          }
        }, true);
      },
      getEditablePools (page) {
        let extra = {
          can_allocate: true
        };
        this.getPools(extra, page);
      },
      getFavoritePools (page) {
        let extra = {
          favorite_only: true
        };
        this.getPools(extra, page);
      },
      getAllPools (page) {
        this.getPools({}, page);
      },
      toggleOrder () {
        this.current_order = this.current_order === 'asc' ? 'desc' : 'asc';
        this.getPage(this.current_page);
      },
      searchPools (pattern) {
        if (pattern) {
          this.$router.push({name: 'pools-search', params: {pattern: pattern}});
        }
      },
      addPool () {
        this.$eventBus.$emit('open_modal', 'ip_pool_add');
      },
      removePool (pool) {
        this.$eventBus.$emit('open_modal', 'ip_pool_remove', pool);
      },
      reloadPools () {
        this.getPage(1);
      }
    },
    mounted () {
      if (this.$route.hash) {
        this.current_tab = this.$route.hash.substring(1);
      }
      this.getPage(1);
      this.$eventBus.$on('reload_ip_pools', this.reloadPools);
      this.$eventBus.$on('search', this.searchPools);
    },
    beforeDestroy () {
      this.$eventBus.$off('search');
    }
  };
</script>
