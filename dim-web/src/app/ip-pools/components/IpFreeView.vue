<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Free IP: {{ ip }}</p>
      <button class="delete" aria-label="close" v-on:click="closeModal"></button>
    </header>
    <section class="modal-card-body">
      <span>Are you sure you want to free this IP address?</span>
      <a class="is-pulled-right" v-on:click="showTable = !showTable">
          <span class="icon has-icons-left">
            <i class="fa fa-chevron-down"></i>
          </span>
        details
      </a>
      <br><br>

      <table class="table is-fullwidth" v-show="showTable">
        <tbody>
        <tr v-for="(value, key) in details">
          <th class="is-capitalized">{{ key }}</th>
          <td>{{ value }}</td>
        </tr>
        </tbody>
      </table>

      <div v-if="records.length > 0" class="section">
        <article class="message is-warning">
          <div class="message-body">
            The following referenced resource records will be automatically deleted.
          </div>
        </article>

          <table class="table">
            <thead>
            <tr>
              <th>Record</th>
              <th>Type</th>
              <th>TTL</th>
              <th>View</th>
              <th>Zone</th>
              <th>Value</th>
            </tr>
            </thead>
            <tbody>
            <tr v-for="record in records">
              <td>{{ record.record }}</td>
              <td>{{ record.type }}</td>
              <td>{{ record.ttl }}</td>
              <td>{{ record.view }}</td>
              <td>{{ record.zone }}</td>
              <td>{{ record.value }}</td>
            </tr>
            </tbody>
          </table>
      </div>

      <div v-if="records.length === 0">
        <div class="message is-link">
          <div class="message-body">
            No resource records found to delete for the current zone.
          </div>
        </div>
      </div>
    </section>
    <footer class="modal-card-foot columns">
      <div class="column is-full">
        <button class="button" v-on:click="closeModal">Cancel</button>
        <button class="button is-danger is-pulled-right" v-on:click="freeIp">
          Yes, free this IP
        </button>
      </div>
    </footer>
  </div>

</template>

<script>
  export default {
    name: 'ip-free-view',
    props: ['ip'],
    data () {
      return {
        details: {},
        showTable: false,
        records: []
      };
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      freeIp () {
        this.closeModal();
        this.jsonRpc('ip_free',
          [this.ip, {pool: this.details.pool, include_messages: true, layer3domain: this.$config.DEFAULT_LAYER3DOMAIN}],
          (response) => {
            if (response.data.result) {
              if (response.data.result.messages.length > 0) {
                this.$eventBus.$emit('open_modal', 'messages', {'messages': response.data.result.messages});
              }
              this.$eventBus.$emit('refresh_ips');
            }
          }
        );
      },
      createFQDN (record) {
        return record.record + '.' + record.zone + '.';
      },
      stripFQDN (record) {
        return record.name.replace('.' + record.zone + '.', '');
      },
      addRecord (record) {
        let fields = ['record', 'type', 'ttl', 'zone', 'value'];
        let value = {
          record: record.name ? this.stripFQDN(record) : record.record,
          type: record.type,
          ttl: record.ttl ? record.ttl : null,
          zone: record.zone ? record.zone : null,
          value:
            typeof record.value !== 'object'
              ? record.value
              : Object.values(record.value).reduce((old, current) => old + ',' + current)
        };
        for (let i = 0; i < this.records.length; i++) {
          let same = fields.every((field) => this.records[i][field] === value[field]);
          if (same) {
            return;
          }
        }
        this.records.push(value);
      },
      getReferences (record) {
        let params = Object.assign({}, record.value);
        params.name = this.createFQDN(record);
        params.delete = true;
        params.type = record.type;
        params.view = record.view;
        this.jsonRpc('rr_get_references', [params], (response) => {
          if (response.data.result) {
            for (let i = 0; i < response.data.result.records.length; i++) {
              let refRecord = response.data.result.records[i];
              if (refRecord.id !== response.data.result.root) {
                this.addRecord(refRecord);
                this.getReferences(refRecord);
              }
            }
          }
        });
      }
    },
    mounted () {
      this.jsonRpc('ipblock_get_attrs', [this.ip, {host: true, layer3domain: this.$config.DEFAULT_LAYER3DOMAIN}],
        (response) => {
          if (response.data.result) {
            this.details = response.data.result;
          }
        }
      );
      let params = [{
        fields: true,
        limit: 100,
        pattern: this.ip,
        value_as_object: true,
        view: null,
        zone: null,
        layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
      }];
      this.jsonRpc('rr_list2', params, (response) => {
        if (response.data.result) {
          for (let i = 0; i < response.data.result.data.length; i++) {
            let record = response.data.result.data[i];
            this.addRecord(record);
          }
          for (let i = 0; i < response.data.result.data.length; i++) {
            let record = response.data.result.data[i];
            this.getReferences(record);
          }
        }
      });
    }
  };
</script>
