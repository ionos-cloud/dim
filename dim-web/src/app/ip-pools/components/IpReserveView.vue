<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Reserve IP: {{ ip }}</p>
      <button class="delete" aria-label="close" v-on:click="closeModal"></button>
    </header>
    <section class="modal-card-body">
      <a class="is-pulled-right" v-on:click="showTable = !showTable">
          <span class="icon has-icons-left">
            <i class="fa fa-chevron-down"></i>
          </span>
        details
      </a>

      <table class="table is-fullwidth" v-show="showTable">
        <tbody>
        <tr v-for="(value, key) in details">
          <th class="is-capitalized">{{ key }}</th>
          <td>{{ value }}</td>
        </tr>
        </tbody>
      </table>

      <div class="field">
        <label class="label has-text-weight-semibold">
          Configure IP
        </label>
          <div class="control">
            <label class="radio">
              <input type="radio" v-model="config" name="config" value="yes">
              yes
            </label>
            <label class="radio">
              <input type="radio" v-model="config" name="config" value="no">
              no
            </label>
        </div>
      </div>

      <div>
        <div class="field" v-show="config === 'yes'">
          <label class="label has-text-weight-semibold">
            Record
          </label>
          <div class="control has-icons-left has-icons-right">
            <input class="input" name="name" v-validate.initial="'required'" v-model="reservation.name">

            <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
            <span class="icon is-small is-right" v-show="errors.has('name')">
              <i class="fa fa-exclamation-triangle"></i>
            </span>
          </div>
          <p v-show="errors.has('name')" class="help is-danger">{{ errors.first('name') }}</p>
        </div>

        <div class="field" v-show="config === 'yes'">
          <label class="label has-text-weight-semibold">
            Zone
          </label>

          <div class="control has-icons-left has-icons-right">
            <v-select v-model="reservation.zone" name="zone"
                      v-validate.initial="'required'" :options="zones" @search="onSearch" label="name"></v-select>
          </div>

          <p v-show="errors.has('zone')" class="help is-danger">{{ errors.first('zone') }}</p>
        </div>

        <div class="field" v-show="config === 'yes'">
          <label class="label has-text-weight-semibold">
            Views
          </label>

          <div class="control has-icons-left has-icons-right">
            <div class="select is-fullwidth is-multiple">
              <select v-model="reservation.views" name="views" multiple v-validate.initial="'required'"
                      :disabled="views.length === 0">
                <option v-for="view in views" :value="view.name">{{ view.name }}</option>
              </select>
            </div>

            <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
            <span class="icon is-small is-right" v-show="errors.has('views')">
              <i class="fa fa-exclamation-triangle"></i>
            </span>
          </div>
          <p v-show="errors.has('views')" class="help is-danger">{{ errors.first('views') }}</p>
        </div>

        <div class="field">
          <label class="label has-text-weight-semibold">Comment</label>
          <div class="control has-icons-right">
            <textarea class="textarea" name="comment" v-model="reservation.comment" maxlength="255"></textarea>
          </div>
        </div>
      </div>
    </section>
    <footer class="modal-card-foot columns">
      <div class="column is-full">
        <button class="button" v-on:click="closeModal">Cancel</button>
        <button class="button is-danger is-pulled-right" v-on:click="reserveIP" :disabled="disabled">
          Reserve this IP
        </button>
      </div>
    </footer>
  </div>

</template>

<script>
  import debounce from 'debounce';

  export default {
    name: 'ip-reserve-view',
    props: ['ip'],
    data () {
      return {
        details: {},
        config: 'yes',
        zones: [],
        reservation: {
          name: '',
          zone: '',
          comment: '',
          views: []
        },
        showTable: false
      };
    },
    computed: {
      disabled: function () {
        return this.config === 'yes' && this.errors.any();
      },
      views: function () {
        return this.reservation.zone ? this.reservation.zone.views : [];
      }
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      createFQDN (record) {
        return record.name + '.' + record.zone.name + '.';
      },
      reserveIP () {
        this.markIp();
      },
      createARecord () {
        let params = {
          name: this.createFQDN(this.reservation),
          type: 'A',
          ip: this.ip,
          views: this.reservation.views,
          comment: this.reservation.comment
        };
        this.jsonRpc('rr_create', [params], (response) => {
          if (response.data.result) {
            if (response.data.result.messages) {
              this.$eventBus.$emit('open_modal', 'messages', {'messages': response.data.result.messages});
            }
          } else if (response.data.error) {
            this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
          }
        });
      },
      markIp () {
        let params = [
          this.ip,
          {
            pool: this.$route.params.pool_name,
            attributes: {
              comment: this.reservation.comment
            },
            layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
          }
        ];
        this.closeModal();
        this.jsonRpc('ip_mark', params, (response) => {
          this.$eventBus.$emit('refresh_ips');
          if (response.data.result) {
            if (this.config === 'yes') {
              this.createARecord();
            }
          } else if (response.data.error) {
            this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
          }
        });
      },
      onSearch (search, loading) {
        if (search.length > 2) {
          loading(true);
          this.searchZones(loading, search);
        }
      },
      searchZones: debounce(function (loading, search) {
        this.zones = [];
        this.reservation.views = [];
        let params = [{
          can_create_rr: true,
          fields: true,
          limit: this.$config.PAGE_SIZES[0],
          pattern: '*' + search + '*'
        }];
        this.jsonRpc('zone_list2', params, (response) => {
          if (response.data.result) {
            this.zones = response.data.result.data;
            loading(false);
          }
        });
      }, 500)
    },
    mounted () {
      let params = [this.ip, {host: true, layer3domain: this.$config.DEFAULT_LAYER3DOMAIN}];
      this.jsonRpc('ipblock_get_attrs', params, (response) => {
        if (response.data.result) {
          this.details = response.data.result;
        }
      });
    }
  };
</script>
