<template>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title" >Edit resource record</p>
        <button class="delete" aria-label="close" v-on:click="closeModal"></button>
      </header>
      <section class="modal-card-body">
        <div class="tabs">
          <ul>
            <li :class="{'is-active': tab === 'form'}"><a v-on:click="toggleTab('form')">Records</a></li>
            <li :class="{'is-active': tab === 'references'}"><a v-on:click="toggleTab('references')">References</a></li>
          </ul>
        </div>

        <div v-show="tab === 'form'">
          <div class="field" v-for="field in typeFields">
            <label class="label has-text-weight-semibold">
              {{ field.label }}
            </label>
            <div class="control has-icons-left has-icons-right">

              <div v-if="field.name === 'type'" class="select is-fullwidth">
                <select v-model="record.type" name="type" disabled>
                  <option v-for="recordType in $config.RR_TYPES" :value="recordType"> {{ recordType }}</option>
                </select>
              </div>

              <div v-else-if="field.name === 'views'" class="select is-fullwidth is-multiple">
                <select v-model="record.views" name="views" multiple v-on:change="refreshString">
                  <option v-for="view in views" :value="view"> {{ view }}</option>
                </select>
              </div>

              <input v-else class="input" :name="field.name" v-validate.initial="field.validation"
                     v-model="record[field.name]" v-on:change="refreshString">
              <p class="help" v-if="field.name === 'name' && !record.name">An empty record name will create a record containing @ symbol.</p>

              <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
              <span class="icon is-small is-right" v-show="errors.has(field.name)">
              <i class="fa fa-exclamation-triangle"></i>
            </span>
            </div>
            <p v-show="errors.has(field.name)" class="help is-danger">{{ errors.first(field.name) }}</p>
          </div>

          <div class="field">
            <label class="label has-text-weight-semibold">Comment</label>
            <div class="control has-icons-right">
              <textarea class="textarea" name="comment" v-model="record.comment" maxlength="255" v-on:change="refreshString"></textarea>
            </div>
          </div>
        </div>

        <div v-show="tab === 'references'">
          <div v-if="references.records.length > 1">
            Select which resource record references will be modified:
            <br><br>
            <reference-view :records="references.records"
                            :id="references.root"
                            :depth="0"
                            :edit="true"
                            :graph="references.graph"></reference-view>
          </div>
          <div v-else>
            No references available.
          </div>
        </div>

      </section>
      <footer class="modal-card-foot columns is-multiline">
        <div class="column is-full">
          <button class="button" v-on:click="closeModal">Cancel</button>
          <button class="button is-link is-pulled-right" v-on:click="toggleTab('references')" v-if="tab === 'form'">
            Next
          </button>
          <button class="button is-link is-pulled-right" v-on:click="editRecord" v-bind:disabled="disabled" v-else>
            Edit resource record
          </button>
        </div>
      </footer>
    </div>
</template>

<script>
  import ReferenceView from './ReferenceView.vue';

  export default {
    name: 'record-edit-view',
    props: ['initial'],
    components: {
      ReferenceView
    },
    data () {
      return {
        record: {
          type: 'A',
          views: [this.$route.params.view_name],
          comment: '',
          references: []
        },
        references: {
          root: 1,
          graph: {1: []},
          records: []
        },
        views: [],
        tab: 'form',
        initialString: '',
        recordString: ''
      };
    },
    computed: {
      typeFields: function () {
        return this.$config.RR_FIELDS_BY_TYPE[this.record.type];
      },
      disabled: function () {
        return (
          this.recordString === this.initialString ||
          this.errors.any()
        );
      }
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
      parseRecordData (record) {
        let params = {};
        let fields = this.$config.RR_FIELDS_BY_TYPE[record.type];
        for (let i = 0; i < fields.length; i++) {
          if (record.hasOwnProperty(fields[i].name) && record[fields[i].name] != null && record[fields[i].name] !== '') {
            if (fields[i].name === 'views') {
              params[fields[i].name] = record[fields[i].name];
            } else {
              params[fields[i].name] = String(record[fields[i].name]);
            }
          }
        }
        params.name = this.createFQDN(record.name);
        params.comment = record.comment;
        params.references = record.references === undefined ? [] : record.references;
        delete params.type;
        return params;
      },
      editRecord () {
        this.closeModal();
        this.jsonRpc('rr_edit', [this.references.root, this.parseRecordData(this.record)],
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
              this.$eventBus.$emit('open_modal', 'record_edit', this.record);
            }
          }
        );
      },
      toggleTab (tab) {
        this.tab = tab;
      },
      addReference (reference) {
        this.record.references.push(reference);
        this.refreshString();
      },
      removeReference (reference) {
        this.record.references = this.record.references.filter(item => item !== reference);
        this.refreshString();
      },
      refreshString () {
        this.recordString = JSON.stringify(this.parseRecordData(this.record));
      }
    },
    created () {
      if (this.initial) {
        this.record = Object.assign({}, this.initial);
        this.record.references = [];
        this.initialString = JSON.stringify(this.parseRecordData(this.initial));
        this.refreshString();
      }
      this.$eventBus.$on('check_reference', this.addReference);
      this.$eventBus.$on('uncheck_reference', this.removeReference);
    },
    mounted () {
      this.jsonRpc('zone_list_views', [this.$route.params.zone_name],
        (response) => {
          if (response.data.result) {
            this.views = response.data.result.map((item) => { return item.name; });
          }
        }
      );
      let params = Object.assign({}, this.record);
      params.name = this.createFQDN(params.name);
      params.delete = false;
      params.view = params.views[0];
      delete params.ttl;
      delete params.views;
      delete params.zone;
      delete params.comment;
      delete params.references;

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
