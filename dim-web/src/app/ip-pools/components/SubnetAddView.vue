<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Add subnet</p>
      <button class="delete" aria-label="close" v-on:click="closeModal"></button>
    </header>
    <section class="modal-card-body">
      <div class="field">
        <label class="label has-text-weight-semibold">
          Subnet CIDR
        </label>
        <div class="control has-icons-left">
          <input class="input" name="cidr" v-model="details.cidr" v-validate.initial="'required'">
          <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
        </div>
        <p v-show="errors.has('cidr')" class="help is-danger">{{ errors.first('cidr') }}</p>
      </div>

      <div class="field">
        <label class="label has-text-weight-semibold">
          Pool
          <p class="is-pulled-right has-text-weight-normal pointer" v-on:click="createPool" v-if="attrs.createPool">
            <span class="icon has-text-success">
              <i class="fa fa-plus"></i>
            </span>Create a new pool
          </p>
        </label>

        <div class="control has-icons-left has-icons-right">
          <v-select v-model="details.pool" name="pool"
                    v-validate.initial="'required'" :options="pools" @search="onSearch" label="name"></v-select>
        </div>

        <p v-show="errors.has('pool')" class="help is-danger">{{ errors.first('pool') }}</p>
      </div>

      <div class="field">
        <label class="label has-text-weight-semibold">
          Gateway
        </label>
        <div class="control has-icons-left">
          <input class="input" name="gateway" v-model="details.gateway">
          <span class="icon is-small is-left">
                <i class="fa fa-pencil"></i>
              </span>
        </div>
        <p v-show="errors.has('gateway')" class="help is-danger">{{ errors.first('gateway') }}</p>
      </div>
    </section>
    <footer class="modal-card-foot columns">
      <div class="column is-full">
        <button class="button" v-on:click="closeModal">Cancel</button>
        <button class="button is-link is-pulled-right" v-on:click="addSubnet" :disabled="disabled">
          Add subnet
        </button>
      </div>
    </footer>
  </div>
</template>

<script>
  import debounce from 'debounce';

  export default {
    name: 'subnet-add-view',
    data () {
      return {
        searching: false,
        results: false,
        pools: [],
        details: {cidr: '', pool: '', gateway: ''}
      };
    },
    props: ['attrs'],
    computed: {
      disabled: function () {
        return this.errors.any();
      }
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      addSubnet () {
        let options = {
          include_messages: true
        };
        if (this.details.gateway) {
          options.gateway = this.details.gateway;
        }
        this.closeModal();
        this.jsonRpc('ippool_add_subnet', [this.details.pool.name, this.details.cidr, options],
          (response) => {
            if (response.data.result) {
              if (this.$route.path === '/ip-spaces') {
                this.$eventBus.$emit('open_modal', 'messages',
                  {'messages': response.data.result.messages, 'refresh_event': 'refresh_tree'});
              } else {
                this.$eventBus.$emit('open_modal', 'messages',
                  {'messages': response.data.result.messages, 'refresh_event': 'refresh_ips'});
              }
            }
            if (response.data.error) {
              this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
              this.$eventBus.$emit('open_modal', 'subnet_add', this.details);
            }
          }
        );
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
      }, 500),
      createPool () {
        this.closeModal();
        let options = Object.assign({}, this.details);
        options.options = [];
        this.$eventBus.$emit('open_modal', 'ip_pool_add', options);
      }
    },
    created () {
      this.details = this.attrs;
    },
    mounted () {
      if (this.details.pool) {
        this.pools = [this.attrs.pool];
      }
    }
  };
</script>
