<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Add delegation</p>
      <button class="delete" aria-label="close" v-on:click="closeModal"></button>
    </header>
    <section class="modal-card-body">
      <div class="field">
        <label class="label has-text-weight-semibold">
          CIDR
        </label>
        <div class="control has-icons-left">
          <input class="input" name="cidr" v-model="attrs.cidr" v-validate.initial="'required'">
          <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
        </div>
        <p v-show="errors.has('cidr')" class="help is-danger">{{ errors.first('cidr') }}</p>
      </div>

      <div class="field">
        <label class="label has-text-weight-semibold">
          Pool
        </label>

        <div class="control has-icons-left has-icons-right">
          <v-select v-model="attrs.pool" name="pool"
                    v-validate.initial="'required'" :options="pools" @search="onSearch" label="name"></v-select>
        </div>

        <p v-show="errors.has('pool')" class="help is-danger">{{ errors.first('pool') }}</p>
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
        <button class="button is-link is-pulled-right" v-on:click="addDelegation" :disabled="disabled">
          Create delegation
        </button>
      </div>
    </footer>
  </div>
</template>

<script>
  import debounce from 'debounce';

  export default {
    name: 'delegation-add-view',
    data () {
      return {
        pools: []
      };
    },
    props: {
      attrs: {
        default () {
          return {cidr: '', pool: '', options: [], ipversion: 4};
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
      },
      addDelegation () {
        let params = {
          status: 'Delegation',
          pool: this.attrs.pool.name,
          attributes: {},
          layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
        };
        for (let i = 0; i < this.attrs.options.length; i++) {
          if (this.attrs.options[i].value !== '') {
            params.attributes[this.attrs.options[i].key] = this.attrs.options[i].value;
          }
        }
        this.closeModal();
        this.jsonRpc('ipblock_create', [this.attrs.cidr, params], (response) => {
          if (response.data.result) {
            this.$nextTick(() => {
              this.$eventBus.$emit('refresh_ips');
            });
          } else if (response.data.error) {
            this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
            this.$eventBus.$emit('open_modal', 'delegation_add', this.attrs);
          }
        });
      },
      onSearch (search, loading) {
        if (search.length > 2) {
          loading(true);
          this.searchPools(loading, search);
        }
      },
      searchPools: debounce(function (loading, search) {
        let params = [{
          offset: this.current_offset,
          limit: this.$config.PAGE_SIZES[0],
          fields: true,
          pool: '*' + search + '*'
        }];
        this.jsonRpc('ippool_list2', params, (response) => {
          if (response.data.result) {
            this.pools = response.data.result.data;
            loading(false);
          }
        });
      }, 500)
    },
    mounted () {
      if (this.attrs.pool.name) {
        this.pools = [this.attrs.pool];
      }
      this.$validator.attach('opt_validate', 'unique-keys');
    }
  };
</script>
