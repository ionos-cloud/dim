<template>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">Remove resource record</p>
        <button class="delete" aria-label="close" v-on:click="closeModal"></button>
      </header>
      <section class="modal-card-body">
        Are you sure you want remove this Resource Record?

        <a class="is-pulled-right" v-on:click="showTable = !showTable">
          <span class="icon has-icons-left">
            <i class="fa fa-chevron-down"></i>
          </span>
          details
        </a>

        <table class="table is-fullwidth" v-show="showTable">
          <tbody>
            <tr>
              <th>record</th>
              <td>{{ record.record }}</td>
            </tr>
            <tr>
              <th>ttl</th>
              <td>{{ record.ttl }}</td>
            </tr>
            <tr>
              <th>type</th>
              <td>{{ record.type }}</td>
            </tr>
            <tr>
              <th>value</th>
              <td>
                <div class="field is-grouped is-grouped-multiline">
                  <div v-for="(value, key) in record.value" class="control">
                    <div class="tags has-addons">
                      <span class="tag is-link">{{ key }}</span>
                      <span class="tag">{{ value }}</span>
                    </div>
                  </div>
                </div>
              </td>
            </tr>
            <tr>
              <th>view</th>
              <td>{{ record.view }}</td>
            </tr>
            <tr>
              <th>zone</th>
              <td>{{ record.zone }}</td>
            </tr>
          </tbody>
        </table>

        <div v-if="references.records.length > 1">
          These resource record references will be removed too:
          <br><br>
          <reference-view :records="references.records"
                          :id="references.root"
                          :depth="0"
                          :edit="false"
                          :graph="references.graph"></reference-view>
        </div>

      </section>
      <footer class="modal-card-foot columns is-multiline">
        <div class="column is-full">
          <input type="checkbox" class="checkbox" v-model="keep_ips"> Keep IP reservations
        </div>
        <div class="column is-full">
          <input type="checkbox" class="checkbox" v-model="force"> Force Delete
        </div>
        <div class="column is-full">
          <button class="button" v-on:click="closeModal">Cancel</button>
          <button class="button is-danger is-pulled-right" v-on:click="removeRecord">
            Yes, remove resource record
          </button>
        </div>
      </footer>
    </div>
</template>

<script>
  import ReferenceView from './ReferenceView.vue';

  export default {
    name: 'record-remove-view',
    props: ['record'],
    components: {
      ReferenceView
    },
    data () {
      return {
        references: {
          root: 1,
          graph: {1: []},
          records: []
        },
        showTable: false,
        keep_ips: false,
        force: false
      };
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      createFQDN (name) {
        if (!name || name === '@') {
          return this.$route.params.zone_name + '.';
        }
        return name + '.' + this.$route.params.zone_name + '.';
      },
      removeRecord () {
        let params = Object.assign({}, this.record.value);
        params.type = this.record.type;
        params.name = this.createFQDN(this.record.record);
        params.zone = this.record.zone;
        params.views = [this.record.view];
        params.free_ips = !this.keep_ips;

        if (this.force) {
          params.references = 'ignore';
        }

        this.closeModal();
        this.jsonRpc('rr_delete', [params],
          (response) => {
            if (response.data.result) {
              if (response.data.result.messages) {
                this.$eventBus.$emit('reload_records');
                if (response.data.result.messages.length > 0) {
                  this.$eventBus.$emit('open_modal', 'messages', {'messages': response.data.result.messages});
                }
              }
            } else if (response.data.error) {
              this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
            }
          }
        );
      }
    },
    mounted () {
      let params = Object.assign({}, this.record.value);
      params.name = this.createFQDN(this.record.record);
      params.delete = true;
      params.type = this.record.type;
      params.view = this.record.view;

      this.jsonRpc('rr_get_references', [params], (response) => {
        if (response.data.result) {
          this.references.root = response.data.result.root;
          this.references.records = response.data.result.records;
          this.references.graph = response.data.result.graph;
        }
      });
    }
  };
</script>
