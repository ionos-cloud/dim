<template>
  <div id="zones-list-view" class="container is-fluid">
    <div class="tabs">
      <ul>
        <li :class="{'is-active': current_tab === 'favorite'}">
          <a v-on:click="getTab('favorite')">Favorite Zones</a>
        </li>
        <li :class="{'is-active': current_tab === 'popular'}">
          <a v-on:click="getTab('popular')">Popular Zones</a>
        </li>
        <li :class="{'is-active': current_tab === 'edit'}">
          <a v-on:click="getTab('edit')">Editable Zones</a>
        </li>
        <li :class="{'is-active': current_tab === 'forward'}">
          <a v-on:click="getTab('forward')">Forward Zones</a>
        </li>
        <li :class="{'is-active': current_tab === 'ipv4'}">
          <a v-on:click="getTab('ipv4')">IPv4 Reverse Zones</a>
        </li>
        <li :class="{'is-active': current_tab === 'ipv6'}">
          <a v-on:click="getTab('ipv6')">IPv6 Reverse Zones</a>
        </li>
      </ul>
    </div>
    <section v-if="zones_count">
      <article class="message is-info is-small">
        <div class="message-body">
          <span v-if="zones_count > 1">
            {{ zones_count }} zones found.
          </span>
          <span v-else>
            1 zone found.
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
        </tr>
        </thead>
        <tbody>
        <tr v-for="(zone, i) in zones">
          <td>{{ (current_page - 1) * page_size + i + 1 }}</td>
          <td>
            <span class="icon is-small is-left" v-if="zone.dnssec">
              <i class="fa fa-lock"></i>
            </span> {{ zone.name }}
            <span class="tags is-inline">
              <span v-for="view in zone.views"
                    class="pointer"
                    :class="view.can_create_rr && view.can_delete_rr ? 'tag has-text-info' : 'tag has-text-grey'">
                <span class="icon is-left" v-if="view.dnssec">
                  <i class="fa fa-lock"></i>
                </span>
                <router-link :to="{ name: 'zone', params: {zone_name: zone.name, view_name: view.name} }">
                  {{ view.name }}
                </router-link>
              </span>
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
    <section v-else>
      <article class="message is-warning is-small">
        <div class="message-body">
          No corresponding zones found.
        </div>
      </article>
    </section>
  </div>
</template>
<script>
  export default {
    name: 'zones-list-view',
    data () {
      return {
        zones: [],
        zones_count: 0,
        current_offset: 0,
        current_tab: 'favorite',
        current_page: 1,
        current_order: 'asc',
        min_page: 1,
        max_page: 1,
        mapping: {
          'edit': this.getEditableZones,
          'forward': this.getForwardZones,
          'favorite': this.getFavoriteZones,
          'popular': this.getPopularZones,
          'ipv4': this.getIpv4ReverseZones,
          'ipv6': this.getIpv6ReverseZones
        },
        page_size: 10
      };
    },
    watch: {
      '$route.hash' (newValue, oldValue) {
        if (newValue) {
          this.current_tab = this.$route.hash.substring(1);
        }
        this.current_order = 'asc';
        this.zones_count = 0;
        this.zones = [];
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
      getZone (extra, page) {
        let params = [{
          offset: this.current_offset,
          limit: this.page_size,
          fields: true,
          order: this.current_order,
          ...extra
        }];
        this.jsonRpc('zone_list2', params, (response) => {
          if (response.data.result) {
            this.zones_count = response.data.result.count;
            this.max_page = Math.ceil(this.zones_count / this.page_size);
            this.zones = response.data.result.data;
            this.current_page = page;
          }
        }, true);
      },
      getEditableZones (page) {
        let extra = {
          can_delete_rr: true,
          can_create_rr: true
        };
        this.getZone(extra, page);
      },
      getFavoriteZones (page) {
        let extra = {
          favorite_only: true
        };
        this.getZone(extra, page);
      },
      getPopularZones (page) {
        this.zones_count = this.$config.POPULAR_ZONES.length;
        this.max_page = Math.ceil(this.zones_count / this.page_size);
        let zones = this.$config.POPULAR_ZONES;
        zones.sort((a, b) => {
          return (a.name < b.name ? -1 : (a.name > b.name ? 1 : 0)) *
            (this.current_order === 'asc' ? 1 : -1);
        });
        this.zones = zones.slice(
          this.current_offset, this.current_offset + this.page_size);
        this.current_page = page;
        for (let i = 0; i < this.zones.length; i++) {
          let params = [{
            limit: 1,
            fields: true,
            pattern: this.zones[i].name
          }];
          this.jsonRpc('zone_list2', params, (response) => {
            if (response.data.result) {
              this.zones.splice(i, 1, response.data.result.data[0]);
            }
          }, true);
        }
      },
      getForwardZones (page) {
        this.getZone({}, page);
      },
      getIpv4ReverseZones (page) {
        let extra = {
          forward_zones: false,
          ipv4_reverse_zones: true
        };
        this.getZone(extra, page);
      },
      getIpv6ReverseZones (page) {
        let extra = {
          forward_zones: false,
          ipv6_reverse_zones: true
        };
        this.getZone(extra, page);
      },
      toggleOrder () {
        this.current_order = this.current_order === 'asc' ? 'desc' : 'asc';
        this.getPage(this.current_page);
      },
      searchZone (pattern) {
        if (pattern) {
          this.$router.push({name: 'zones-search', params: {pattern: pattern}});
        }
      }
    },
    mounted () {
      this.$eventBus.$on('search', this.searchZone);
      if (!this.$cookies.get('REDIRECT') || this.$cookies.get('REDIRECT') === '/') {
        if (this.$route.hash) {
          this.current_tab = this.$route.hash.substring(1);
        }
      }
      this.getPage(1);
    },
    beforeDestroy () {
      this.$eventBus.$off('search');
    }
  };
</script>
