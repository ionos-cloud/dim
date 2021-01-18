<template>
  <div id="zones-list-search" class="container is-fluid">
    <br>
    <section v-if="zones_count">
      <article class="message is-info is-small">
        <div class="message-body">
          <span v-if="zones_count > 1">
            {{ zones_count }} zones found matching "{{ pattern }}".
          </span>
          <span v-else>
            1 zone found.
          </span>
        </div>
      </article>
      <table class="table is-fullwidth is-hoverable">
        <thead>
        <tr v-on:click="toggleOrder">
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
          <td>{{ current_offset + i + 1 }}</td>
          <td>
            <span class="icon is-small is-left" v-if="zone.dnssec">
              <i class="fa fa-lock"></i>
            </span> {{ zone.name }}
            <span class="tags is-inline">
              <span v-for="view in zone.views"
                    :class="view.can_create_rr && view.can_delete_rr ? 'tag has-text-info' : 'tag has-text-grey'">
                <span class="icon is-left" v-if="view.dnssec">
                  <i class="fa fa-lock"></i>
                </span>
                <router-link :to="{ name: 'zone', params: {zone_name: zone.name, view_name: view.name} }" class="pointer">
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
          No zones found matching "{{ pattern }}".
        </div>
      </article>
    </section>
  </div>

</template>

<script>
  export default {
    name: 'zone-search-view',
    data () {
      return {
        zones: [],
        zones_count: 0,
        current_offset: 0,
        current_page: 1,
        current_order: 'asc',
        min_page: 1,
        max_page: 1,
        pattern: this.$route.params.pattern,
        page_size: 10
      };
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
        this.getZone();
      },
      getZone () {
        let params = [{
          offset: this.current_offset,
          limit: this.page_size,
          fields: true,
          order: this.current_order,
          pattern: '*' + this.pattern + '*',
          forward_zones: true,
          ipv4_reverse_zones: true,
          ipv6_reverse_zones: true
        }];
        this.jsonRpc('zone_list2', params, (response) => {
          if (response.data.result) {
            this.zones_count = response.data.result.count;
            this.max_page = Math.ceil(this.zones_count / this.page_size);
            this.zones = response.data.result.data;
          }
        }, true);
      },
      toggleOrder () {
        this.current_order = this.current_order === 'asc' ? 'desc' : 'asc';
        this.getPage(this.current_page);
      },
      searchZone (pattern) {
        this.$router.push({name: 'zones-search', params: {pattern: pattern}});
        this.pattern = pattern;
        this.getPage(1);
      }
    },
    mounted () {
      this.getPage(1);
      this.$eventBus.$on('search', this.searchZone);
    },
    beforeDestroy () {
      this.$eventBus.$emit('empty_search');
      this.$eventBus.$off('search');
    }
  };
</script>
