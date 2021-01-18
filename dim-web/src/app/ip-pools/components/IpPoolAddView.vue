<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Add IP pool</p>
      <button class="delete" aria-label="close" v-on:click="closeModal"></button>
    </header>
    <section class="modal-card-body">
      <div class="field">
        <label class="label has-text-weight-semibold">
          Name
        </label>
        <div class="control has-icons-left">
          <input class="input" name="name" v-model="attrs.name" v-validate.initial="'required'">
          <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
        </div>
        <p v-show="errors.has('name')" class="help is-danger">{{ errors.first('name') }}</p>
      </div>

      <div class="field">
        <label class="label has-text-weight-semibold">
          VLAN
        </label>
        <div class="control has-icons-left">
          <input class="input" name="vlan" v-model="attrs.vlan" v-validate.initial="'numeric'">
          <span class="icon is-small is-left">
                <i class="fa fa-pencil"></i>
              </span>
        </div>
        <p v-show="errors.has('vlan')" class="help is-danger">{{ errors.first('vlan') }}</p>
      </div>

      <div class="field">
        <label class="label has-text-weight-semibold">Comment</label>
        <div class="control">
          <textarea class="textarea" name="comment" v-model="attrs.comment" maxlength="255"></textarea>
        </div>
      </div>

      <div class="field is-horizontal" v-for="(option, i) in attrs.options">
        <div class="field-body">
          <div class="field">
            <p class="control has-icons-left">
              <input class="input" name='key' v-model="option.key" v-validate.initial="'required'" placeholder="key">
              <span class="icon is-small is-left">
                <i class="fa fa-pencil"></i>
              </span>
            </p>
          </div>
          <div class="field">
            <p class="control has-icons-left">
              <input class="input" name='value' v-model="option.value" v-validate.initial="'required'" placeholder="value">
              <span class="icon is-small is-left">
                <i class="fa fa-pencil"></i>
              </span>
            </p>
          </div>
        </div>
        <span class="icon has-text-danger pointer" v-on:click="removeOption(i)"><i class="fa fa-times"></i></span>
      </div>
      <p v-on:click="addOption" class="is-pulled-right pointer">
        <span class="icon has-text-success"><i class="fa fa-plus"></i></span>Add another option
      </p>

      <p v-show="errors.has('key') || errors.has('value') || errors.has('opt_validate') " class="help is-danger">
        {{ errors.first('key') }} {{ errors.first('value') }} {{ errors.first('opt_validate') }}
      </p>
    </section>
    <footer class="modal-card-foot columns">
      <div class="column is-full">
        <button class="button" v-on:click="closeModal">Cancel</button>
        <button class="button is-link is-pulled-right" v-on:click="addPool" :disabled="disabled">
          Create IP pool
        </button>
      </div>
    </footer>
  </div>
</template>

<script>
  export default {
    name: 'ip-pool-add-view',
    props: {
      attrs: {
        default () {
          return {name: '', vlan: null, comment: '', options: []};
        },
        type: Object
      }
    },
    computed: {
      disabled: function () {
        return this.errors.any();
      },
      opt_validate: function () {
        return this.attrs.options.map(obj => obj.key);
      }
    },
    watch: {
      opt_validate (value) {
        this.$validator.validate('opt_validate', value);
      }
    },
    methods: {
      addOption () {
        this.attrs.options.push({key: '', value: ''});
      },
      removeOption (i) {
        this.attrs.options.splice(i, 1);
      },
      closeModal () {
        this.$eventBus.$emit('close_modal');
        if (this.attrs.cidr) {
          this.$eventBus.$emit('open_modal', 'subnet_add', this.attrs);
        }
      },
      addPool () {
        let options = {
          attributes: {
            comment: this.attrs.comment
          },
          layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
        };
        if (this.attrs.vlan && this.attrs.vlan !== null && this.attrs.vlan !== '') {
          options.vlan = this.attrs.vlan;
        }
        for (let i = 0; i < this.attrs.options.length; i++) {
          if (this.attrs.options[i].value !== '') {
            options.attributes[this.attrs.options[i].key] = this.attrs.options[i].value;
          }
        }
        this.$eventBus.$emit('close_modal');
        this.jsonRpc('ippool_create', [this.attrs.name, options],
          (response) => {
            if (response.data.error) {
              this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
              this.$eventBus.$emit('open_modal', 'ip_pool_add', this.attrs);
            } else if (response.data.result === null) {
              if (this.attrs.cidr) {
                let options = this.attrs;
                options.pool = {name: this.attrs.name};
                this.$eventBus.$emit('open_modal', 'subnet_add', options);
              } else {
                this.$eventBus.$emit('reload_ip_pools');
              }
            }
          }
        );
      }
    },
    mounted () {
      this.$validator.attach('opt_validate', 'unique-keys');
    }
  };
</script>
