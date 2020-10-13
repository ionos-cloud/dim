<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Remove IP pool</p>
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
          <th>Name</th>
          <td>{{ pool.name }}</td>
        </tr>
        <tr>
          <th>Subnets</th>
          <td>
            <ul>
              <li v-for="subnet in pool.subnets">{{ subnet }}</li>
            </ul>
          </td>
        </tr>
        </tbody>
      </table>

      <div class="message is-warning" v-if="pool.subnets.length > 0">
        <div class="message-body">
          This pool won't be deleted since it contains one or more subnets.
          <br>
          <label class="checkbox">
            <input type="checkbox" v-model="force">
            Force delete
          </label>
          <br>
          <label class="checkbox" v-show="force">
            <input type="checkbox" v-model="delete_subnets">
            Force delete subnets
          </label>
        </div>
      </div>

    </section>
    <footer class="modal-card-foot columns">
      <div class="column is-full">
        <button class="button" v-on:click="closeModal">Cancel</button>
        <button class="button is-danger is-pulled-right" v-on:click="removePool" :disabled="disabled">
          Yes, remove this IP pool
        </button>
      </div>
    </footer>
  </div>
</template>

<script>
  export default {
    name: 'ip-pool-remove-view',
    props: ['pool'],
    data () {
      return {
        showTable: false,
        force: false,
        delete_subnets: false
      };
    },
    computed: {
      disabled: function () {
        return !this.force && this.pool.subnets.length > 0;
      }
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      removePool () {
        let params = [this.pool.name];
        if (this.force) {
          params.push({force: this.force, delete_subnets: this.delete_subnets});
        }
        this.closeModal();
        this.jsonRpc('ippool_delete', params, (response) => {
          if (response.data.result) {
            let count = response.data.result;
            if (count === 1) {
              this.$eventBus.$emit('open_modal', 'messages',
                {'messages': [[20, 'Pool was deleted successfully.']], 'refresh_event': 'reload_ip_pools'});
            } else {
              this.$eventBus.$emit('open_modal', 'messages',
                {'messages': [[30, 'Pool wasn\'t deleted since it had subnets and force wasn\'t specified.']]});
            }
          } else if (response.data.error) {
            this.$eventBus.$emit('open_modal', 'messages', {'error_messages': [response.data.error]});
          }
        });
      }
    }
  };
</script>
