<template>
  <div id="ip-space-list-view" class="container is-fluid">
    <section>
      <div class="tabs is-medium is-fixed-tabs">
        <ul>
          <li :class="{'is-active': ipversion === 4}">
            <a v-on:click="toggleIPVersion(4)">IPv4</a>
          </li>
          <li :class="{'is-active': ipversion === 6}">
            <a v-on:click="toggleIPVersion(6)">IPv6</a>
          </li>
        </ul>
      </div>
    </section>
    <section class="section columns is-content">
      <aside class="menu column is-3 is-sidebar">
        <div class="box">
          <div class="field">
            <label class="label">Type</label>
            <div class="control">
              <label class="checkbox">
                <input type="checkbox" :checked="hasType('Container')" v-on:change="toggleType('Container')">
                <span class="icon has-text-link">
                      <i class="fa fa-archive"></i>
                </span> Container
              </label>
            </div>
            <div class="control">
              <label class="checkbox">
                <input type="checkbox" :checked="hasType('Subnet')" v-on:change="toggleType('Subnet')">
                <span class="icon has-text-link">
                      <i class="fa fa-sitemap"></i>
                </span> Subnet
              </label>
            </div>
            <div class="control">
              <label class="checkbox">
                <input type="checkbox" :checked="hasType('Delegation')" v-on:change="toggleType('Delegation')">
                <span class="icon has-text-link">
                      <i class="fa fa-cube"></i>
                </span> Delegation
              </label>
            </div>
          </div>

          <div class="field">
            <label class="label">Status</label>
            <div class="control">
              <label class="checkbox has-text-link">
                <input type="checkbox" :checked="hasStatus('Static')" v-on:change="toggleStatus('Static')">
                Static
              </label>
            </div>
            <div class="control">
              <label class="checkbox has-text-success">
                <input type="checkbox" :checked="hasStatus('Reserved')" v-on:change="toggleStatus('Reserved')">
                Reserved
              </label>
            </div>
            <div class="control has-text-grey-light">
              <label class="checkbox">
                <input type="checkbox" :checked="hasStatus('Available')" v-on:change="toggleStatus('Available')">
                Available
              </label>
            </div>
            <div class="control">
              <label class="checkbox">
                <input type="checkbox" :checked="hasStatus('Unmanaged')" v-on:change="toggleStatus('Unmanaged')">
                Unmanaged
              </label>
            </div>
          </div>

          <div class="field">
            <label class="label">Attributes</label>
            <div class="control">
                <input class="input" type="text" v-model="attributes_text" placeholder="pool,ptr_target">
            </div>
          </div>

          <div class="buttons">
            <button class="button is-link" v-on:click="refreshTree">Filter</button>
            <button class="button is-link" v-if="can_network_admin" v-on:click="addContainer">Add container</button>
          </div>
        </div>
        <div class="box" v-if="can_network_admin">
          <div class="message is-info">
            <div class="message-body pointer has-text-centered" v-if="show_delete && to_delete">
              The "{{ pretty_to_delete }}" block is selected.
            </div>
            <div class="message-body has-text-centered" v-else-if="show_delete">
              Please select a block to remove
            </div>
            <div class="message-body has-text-centered" v-else>
              Please enable remove if you want to delete a block.
            </div>
          </div>
          <div class="column">
            <button class="button is-link" v-on:click="toggleDelete">
              <span v-if="show_delete">Disable remove</span>
              <span v-else>Enable remove</span>
            </button>
            <button class="button is-danger is-pulled-right" v-if="to_delete" v-on:click="openDeleteModal">
              Remove
            </button>
          </div>
        </div>
      </aside>
      <div class="column is-9 is-offset-3">
        <div>
          <ip-block-view
            :parent="null"
            :ipversion="ipversion"
            :ipblock="null"
            :statuses="statuses"
            :types="types"
            :attributes="attributes"
            :can_network_admin="can_network_admin"
            :show_delete="show_delete"
            :depth="0">IPv{{ ipversion }}
          </ip-block-view>
        </div>
      </div>
    </section>
  </div>
</template>
<script>
  import IpBlockView from './IpBlockView.vue';

  export default {
    components: {IpBlockView},
    name: 'ip-space-list-view',
    props: ['rights'],
    data () {
      return {
        ipversion: 4,
        statuses: ['Static', 'Reserved', 'Available'],
        types: ['Container', 'Subnet', 'Delegation'],
        attributes_text: '',
        children: [],
        show_delete: false,
        to_delete: ''
      };
    },
    computed: {
      attributes: function () {
        return this.attributes_text.split(',')
          .map(item => item.trim())
          .filter(item => item !== '');
      },
      can_network_admin: function () {
        if (this.rights) {
          return this.rights.indexOf('can_network_admin') !== -1;
        }
      },
      pretty_to_delete: function () {
        return this.to_delete.replace(/:0+/g, ':').replace(/::+/g, '::');
      }
    },
    methods: {
      toggleIPVersion (ipversion) {
        this.ipversion = ipversion;
        this.refreshTree();
      },
      toggleStatus (status) {
        if (this.hasStatus(status)) {
          this.statuses = this.statuses.filter(item => item !== status);
        } else {
          this.statuses.push(status);
        }
      },
      hasStatus (status) {
        return this.statuses.indexOf(status) !== -1;
      },
      toggleType (type) {
        if (this.hasType(type)) {
          this.types = this.types.filter(item => item !== type);
        } else {
          this.types.push(type);
        }
      },
      hasType (type) {
        return this.types.indexOf(type) !== -1;
      },
      refreshTree () {
        this.$nextTick(() => {
          this.$eventBus.$emit('refresh_tree');
        });
      },
      addContainer () {
        this.$eventBus.$emit('open_modal', 'container_add',
          {ipversion: this.ipversion, options: []});
      },
      toggleDelete () {
        if (this.show_delete) {
          this.to_delete = '';
        }
        this.show_delete = !this.show_delete;
      },
      clearDelete () {
        this.to_delete = '';
        this.show_delete = false;
      },
      updateToDelete (cidr) {
        this.to_delete = cidr;
      },
      openDeleteModal () {
        this.$eventBus.$emit('open_modal', 'ipblock_remove', this.to_delete);
      }
    },
    mounted () {
      this.$eventBus.$emit('refresh_tree');
      this.$eventBus.$emit('hide_search');
      this.$eventBus.$on('tree_radio', this.updateToDelete);
      this.$eventBus.$on('refresh_tree', this.clearDelete);
    },
    beforeDestroy () {
      this.$eventBus.$emit('show_search');
    }
  };
</script>
