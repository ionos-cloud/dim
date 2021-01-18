<template>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title" v-if="initial">Clone resource record</p>
        <p class="modal-card-title" v-else>Add resource record</p>
        <button class="delete" aria-label="close" v-on:click="closeModal"></button>
      </header>
      <section class="modal-card-body">
        <div class="field" v-for="field in typeFields">
          <label class="label has-text-weight-semibold">
            {{ field.label }}
          </label>
          <div class="control has-icons-left has-icons-right">

            <div v-if="field.name === 'type'" class="select is-fullwidth">
              <select v-model="record.type" name="type">
                <option v-for="recordType in $config.RR_TYPES" :value="recordType"> {{ recordType }}</option>
              </select>
            </div>

            <div v-else-if="field.name === 'views'" class="select is-fullwidth is-multiple">
              <select v-model="record.views" name="views" multiple>
                <option v-for="view in views" :value="view"> {{ view }}</option>
              </select>
            </div>

            <input v-else class="input" :name="field.name"
                   v-validate.initial="field.validation"
                   :key="record.type + '_' + field.name + '_input'"
                   v-model="record[field.name]">
            <p class="help"
               v-if="field.name === 'name' && !record.name && field.validation.indexOf('required') === -1">
              An empty record name will create a record containing @ symbol.
            </p>

            <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
            <span class="icon is-small is-right" v-show="errors.has(field.name)"
                  :key="record.type + '_' + field.name + '_icon'">
              <i class="fa fa-exclamation-triangle"></i>
            </span>
          </div>
          <p v-show="errors.has(field.name)" class="help is-danger"
             :key="record.type + '_' + field.name + '_error'">
            {{ errors.first(field.name) }}
          </p>
        </div>

        <div class="field">
          <label class="label has-text-weight-semibold">Comment</label>
          <div class="control has-icons-right">
            <textarea class="textarea" name="comment" v-model="record.comment" maxlength="255"></textarea>
          </div>
        </div>
      </section>
      <footer class="modal-card-foot columns is-multiline">
        <div class="column is-full">
          <button class="button" v-on:click="closeModal">Cancel</button>
          <button class="button is-link is-pulled-right" v-on:click="createRecord" v-bind:disabled="disabled" v-if="initial">
            Clone resource record
          </button>
          <button class="button is-link is-pulled-right" v-on:click="createRecord" v-bind:disabled="disabled" v-else>
            Add resource record
          </button>
        </div>
        <div class="column is-full" v-if="!initial">
          <label class="is-pulled-right checkbox">
            <input type="checkbox" v-bind:disabled="disabled" v-model="another"> Add another
          </label>
        </div>
      </footer>
    </div>
</template>

<script>
  export default {
    name: 'record-add-view',
    props: ['initial'],
    data () {
      return {
        record: {
          type: 'A',
          views: [this.$route.params.view_name],
          comment: ''
        },
        views: [],
        another: false
      };
    },
    computed: {
      typeFields: function () {
        return this.$config.RR_FIELDS_BY_TYPE[this.record.type];
      },
      disabled: function () {
        return this.errors.any();
      }
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      createFQDN (name) {
        if (!name) {
          return this.$route.params.zone_name + '.';
        }
        return name + '.' + this.$route.params.zone_name + '.';
      },
      createRecord () {
        let params = {};
        let fields = this.$config.RR_FIELDS_BY_TYPE[this.record.type];
        for (let i = 0; i < fields.length; i++) {
          if (this.record.hasOwnProperty(fields[i].name) && this.record[fields[i].name] !== '') {
            params[fields[i].name] = this.record[fields[i].name];
          }
        }
        params.name = this.createFQDN(this.record.name);
        if (params.hasOwnProperty('strings')) {
          params.strings = '"' + params.strings + '"';
        }
        params.comment = this.record.comment;
        this.closeModal();
        this.jsonRpc('rr_create', [params], (response) => {
          if (response.data.result) {
            if (response.data.result.messages) {
              this.$eventBus.$emit('reload_records');
              this.$eventBus.$emit('open_modal', 'messages', {'messages': response.data.result.messages});
              if (this.another) {
                this.$eventBus.$emit('open_modal', 'record_add');
              }
            }
          } else if (response.data.error) {
            this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
            this.$eventBus.$emit('open_modal', 'record_add', this.record);
          }
        });
      }
    },
    created () {
      if (this.initial) {
        this.record = this.initial;
      }
    },
    mounted () {
      this.jsonRpc('zone_list_views', [this.$route.params.zone_name], (response) => {
        if (response.data.result) {
          this.views = response.data.result.map((item) => { return item.name; });
        }
      });
    }
  };
</script>
