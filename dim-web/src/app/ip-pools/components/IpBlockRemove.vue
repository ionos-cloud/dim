<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Remove IPblock {{ cidr }}</p>
      <button class="delete" aria-label="close" v-on:click="closeModal"></button>
    </header>
    <section class="modal-card-body">
      <span>Are you sure you want to remove this IPblock?</span>
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

      <div class="message is-warning">
        <div class="message-body">
          This ipblock could have children. Are you sure you want to delete them too?
          <br>
          <label class="checkbox">
            <input type="checkbox" v-model="recursive">
            Delete recursively
          </label>
        </div>
      </div>
    </section>
    <footer class="modal-card-foot columns">
      <div class="column is-full">
        <button class="button" v-on:click="closeModal">Cancel</button>
        <button class="button is-danger is-pulled-right" v-on:click="removeIpBlock">
          Remove IPblock
        </button>
      </div>
    </footer>
  </div>
</template>

<script>
  export default {
    name: 'ipblock-remove-view',
    props: ['cidr'],
    data () {
      return {
        showTable: false,
        details: {},
        recursive: true
      };
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      getAttrs () {
        this.jsonRpc('ipblock_get_attrs', [this.cidr, {layer3domain: this.$config.DEFAULT_LAYER3DOMAIN}], (response) => {
          this.details = response.data.result;
        });
      },
      removeIpBlock () {
        this.closeModal();
        this.jsonRpc('ipblock_remove',
          [this.cidr, {
            include_messages: true,
            recursive: this.recursive,
            force: this.recursive,
            layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
          }], (response) => {
            if (response.data.result && response.data.result.messages) {
              if (this.$route.path === '/ip-spaces') {
                if (response.data.result.messages.length > 0) {
                  this.$eventBus.$emit('open_modal', 'messages',
                    {'messages': response.data.result.messages, 'refresh_event': 'refresh_tree'});
                } else {
                  this.$eventBus.$emit('refresh_tree');
                }
              } else {
                if (response.data.result.messages.length > 0) {
                  this.$eventBus.$emit('open_modal', 'messages',
                  {'messages': response.data.result.messages, 'refresh_event': 'refresh_ips'});
                } else {
                  this.$eventBus.$emit('refresh_ips');
                }
              }
            }
            if (response.data.error) {
              this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
            }
          });
      }
    },
    mounted () {
      this.getAttrs();
    }
  };
</script>
