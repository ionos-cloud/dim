<template>
<div id="zone-view" class="container is-fluid">
  <section class="hero">
    <div class="hero-body">
      <div>
        <h1 class="title">{{ zone }}
          <span class="icon is-large is-right has-text-warning">
            <i class="far fa-star" v-if="this.is_favorite" v-on:click="removeFromFavorites"></i>
            <i class="fa fa-star-o" v-else v-on:click="addToFavorites"></i>
          </span>
        </h1>
        <h2 class="subtitle">{{ view }}</h2>
        <article class="message is-info is-small" v-if="total_count">
          <div class="message-body">
          <span v-if="total_count > 1">
            {{ total_count }} records<span v-if="pattern"> matching "{{ pattern }}"</span> found.
          </span>
            <span v-else>
            1 record<span v-if="pattern"> matching "{{ pattern }}"</span> found.
          </span>
          </div>
        </article>
        <article class="message is-warning is-small" v-else>
          <div class="message-body">
            No records<span v-if="pattern"> matching "{{ pattern }}"</span> found.
          </div>
        </article>
      </div>
    </div>
  </section>
  <section v-if="total_count">
    <button class="button is-link left-add-button"
            v-on:click="addRecord" v-if="can_create_rr">Add record</button>
    <table class="table is-fullwidth is-hoverable">
      <thead>
      <tr>
        <th v-on:click="toggleSortBy('record')" class="pointer">
          <span class="icon is-left is-small" v-if="sort_by === 'record'">
            <i :class="'fa fa-sort-alpha-' + current_order">
            </i>
          </span> Record
        </th>
        <th v-on:click="toggleSortBy('ttl')" class="pointer">
          <span class="icon is-left is-small" v-if="sort_by === 'ttl'">
            <i :class="'fa fa-sort-alpha-' + current_order">
            </i>
          </span> TTL
        </th>
        <th v-on:click="toggleTypeSort()" class="pointer">
          <span class="icon is-left is-small">
            <i :class="'fa fa-sort-alpha-' + type_sort">
            </i>
          </span> TYPE
        </th>
        <th v-on:click="toggleSortBy('value')" class="pointer">
          <span class="icon is-left is-small" v-if="sort_by === 'value'">
            <i :class="'fa fa-sort-alpha-' + current_order">
            </i>
          </span>
          VALUE
        </th>
        <th></th>
        <th></th>
        <th></th>
      </tr>
      </thead>
      <tbody>
        <tr v-for="record in records">
          <td>{{ record.record}}</td>
          <td>{{ record.ttl }}</td>
          <td>{{ record.type }}</td>
          <td>
            <div class="tags">
              <span v-for="(value, key) in record.value" class="tag tooltip is-tooltip-info" :data-tooltip=key>
                {{ value }}
              </span>
            </div>
          </td>
          <td class="has-icons-left pointer" v-on:click="cloneRecord(record)" v-if="record.can_create_rr">
              <span class="icon is-small is-left is-desktop">
                <i class="fa fa-clone"></i>
              </span> clone
          </td>
          <td v-else></td>
          <td class="has-icons-left pointer" v-on:click="editRecord(record)" v-if="record.can_create_rr">
              <span class="icon is-small is-left is-desktop">
              <i class="fa fa-pencil"></i>
            </span> edit
          </td>
          <td v-else></td>
          <td class="has-icons-left pointer" v-if="record.can_delete_rr" v-on:click="removeRecord(record)">
              <span class="icon is-small is-left is-desktop">
              <i class="fa fa-times"></i>
            </span> remove
          </td>
          <td v-else></td>
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
    name: 'zone-view',
    data () {
      return {
        view: this.$route.params.view_name,
        zone: this.$route.params.zone_name,
        is_favorite: true,
        records: [],
        can_create_rr: false,
        can_delete_rr: false,
        current_offset: 0,
        current_page: 1,
        current_order: 'asc',
        sort_by: 'record',
        type_sort: 'asc',
        min_page: 1,
        max_page: 10,
        total_count: 0,
        pattern: '',
        page_size: 10
      };
    },
    watch: {
      page_size: function () {
        this.getPage(1);
      },
      '$route.query.search' (n, o) {
        if (n === undefined) {
          this.$eventBus.$emit('empty_search');
        }
        this.pattern = n === undefined ? '' : n;
        this.getPage(1);
      }
    },
    mounted () {
      this.getFavorite();
      this.getRights();
      if (Object.keys(this.$route.query).length) {
        this.searchRecords(this.$route.query.search);
      } else {
        this.getPage(1);
      }
      this.$eventBus.$on('search', this.searchRecords);
      this.$eventBus.$on('reload_records', this.reloadRecords);
    },
    methods: {
      getFavorite () {
        let params = [
          this.zone, {
            view: this.view
          }
        ];
        this.jsonRpc('zone_favorite', params, (response) => {
          if (response.data.result !== undefined) {
            this.is_favorite = response.data.result;
          }
        });
      },
      getRights () {
        let params = [
          this.zone, {
            fields: true
          }
        ];
        this.jsonRpc('zone_list_views', params, (response) => {
          if (response.data.result !== undefined) {
            this.can_create_rr = response.data.result.filter((obj) => {
              return obj.name === this.view && obj.can_create_rr;
            }).length > 0;
            this.can_delete_rr = response.data.result.filter((obj) => {
              return obj.name === this.view && obj.can_delete_rr;
            }).length > 0;
          }
        });
      },
      getPage (page) {
        this.current_offset = this.page_size * (page - 1);
        this.getRecords(page);
      },
      getRecords (page) {
        let params = [{
          limit: this.page_size,
          offset: this.current_offset,
          fields: true,
          value_as_object: true,
          view: this.view,
          zone: this.zone,
          order: this.current_order,
          sort_by: this.sort_by,
          type_sort: this.type_sort,
          pattern: this.pattern ? '*' + this.pattern + '*' : '*'
        }];
        this.jsonRpc('rr_list2', params, (response) => {
          if (response.data.result) {
            this.current_page = page;
            this.total_count = response.data.result.count;
            this.max_page = Math.ceil(this.total_count / this.page_size);
            this.records = response.data.result.data;
          }
        }, true);
      },
      addToFavorites () {
        let params = [
          this.zone, {
            view: this.view
          }
        ];
        this.jsonRpc('zone_favorite_add', params, (response) => {
          this.is_favorite = true;
        });
      },
      removeFromFavorites () {
        let params = [
          this.zone, {
            view: this.view
          }
        ];
        this.jsonRpc('zone_favorite_remove', params, (response) => {
          this.is_favorite = false;
        });
      },
      toggleOrder () {
        this.current_order = this.current_order === 'asc' ? 'desc' : 'asc';
        this.getPage(this.current_page);
      },
      toggleSortBy (sortBy) {
        if (sortBy === this.sort_by) {
          this.toggleOrder();
        } else {
          this.sort_by = sortBy;
          this.current_order = 'asc';
          this.getPage(1);
        }
      },
      toggleTypeSort () {
        this.type_sort = this.type_sort === 'asc' ? 'desc' : 'asc';
        this.getPage(1);
      },
      searchRecords (pattern) {
        this.pattern = pattern;
        this.$router.push({query: {search: pattern}});
        this.getPage(1);
      },
      addRecord () {
        this.$eventBus.$emit('open_modal', 'record_add');
      },
      recordDataToForm (record) {
        let recordData = Object.assign({}, record);
        let cleanupFields = ['can_create_rr', 'can_delete_rr', 'value', 'layer3domain', 'record', 'view'];
        for (let key in recordData.value) {
          recordData[key] = recordData.value[key];
        }
        recordData.name = recordData.record;
        recordData.views = [recordData.view];
        for (let i = 0; i < cleanupFields.length; i++) {
          delete recordData[cleanupFields[i]];
        }
        return recordData;
      },
      cloneRecord (record) {
        this.$eventBus.$emit('open_modal', 'record_add', this.recordDataToForm(record));
      },
      editRecord (record) {
        this.$eventBus.$emit('open_modal', 'record_edit', this.recordDataToForm(record));
      },
      removeRecord (record) {
        this.$eventBus.$emit('open_modal', 'record_remove', record);
      },
      reloadRecords () {
        if (this.pattern) {
          this.searchRecords(this.pattern);
        } else {
          this.getPage(1);
        }
      }
    },
    beforeDestroy () {
      this.$eventBus.$off('search');
      this.$eventBus.$emit('empty_search');
    }
  };
</script>
