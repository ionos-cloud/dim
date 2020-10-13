<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Add container</p>
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
          IPv{{ attrs.ipversion }} reverse zones
        </label>

        <div class="control has-icons-left has-icons-right is-expanded">
          <v-select v-model="attrs.reverse_dns_profile"
                    :options="zones" @search="onSearch" label="name" value="name"></v-select>
        </div>
      </div>



      <div class="field">
        <label class="label has-text-weight-semibold">
          RIR
        </label>
        <div class="control has-icons-left">
          <input class="input" name="rir" v-model="attrs.rir" v-validate.initial="'required'">
          <span class="icon is-small is-left">
                <i class="fa fa-pencil"></i>
              </span>
        </div>
        <p v-show="errors.has('rir')" class="help is-danger">{{ errors.first('rir') }}</p>
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
        <button class="button is-link is-pulled-right" v-on:click="addContainer" :disabled="disabled">
          Create container
        </button>
      </div>
    </footer>
  </div>
</template>

<script>
  import debounce from 'debounce';

  export default {
    name: 'container-add-view',
    data () {
      return {
        zones: []
      };
    },
    props: {
      attrs: {
        default () {
          return {cidr: '', rir: '', reverse_dns_profile: null, options: [], ipversion: 4};
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
      addContainer () {
        let params = {
          status: 'Container',
          attributes: {},
          layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
        };
        if (this.attrs.reverse_dns_profile && this.attrs.reverse_dns_profile !== null) {
          params.attributes.reverse_dns_profile = this.attrs.reverse_dns_profile.name;
        }
        for (let i = 0; i < this.attrs.options.length; i++) {
          if (this.attrs.options[i].value !== '') {
            params.attributes[this.attrs.options[i].key] = this.attrs.options[i].value;
          }
        }
        this.closeModal();
        this.jsonRpc('ipblock_create', [this.attrs.cidr, params],
          (response) => {
            if (response.data.result) {
              this.$nextTick(() => {
                this.$eventBus.$emit('refresh_tree');
              });
            } else if (response.data.error) {
              this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
              this.$eventBus.$emit('open_modal', 'container_add', this.attrs);
            }
          }
        );
      },
      onSearch (search, loading) {
        if (search.length > 2) {
          loading(true);
          this.searchZones(loading, search);
        }
      },
      searchZones: debounce(function (loading, search) {
        let params = {
          offset: this.current_offset,
          limit: this.$config.PAGE_SIZES[0],
          fields: true,
          pattern: '*' + search + '*',
          forward_zones: false
        };
        params['ipv' + this.attrs.ipversion + '_reverse_zones'] = true;
        this.jsonRpc('zone_list2', [params], (response) => {
          if (response.data.result) {
            this.zones = response.data.result.data;
            loading(false);
          }
        });
      }, 500)
    },
    mounted () {
      this.$validator.attach('opt_validate', 'unique-keys');
    }
  };
</script>
