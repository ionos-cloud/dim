<template>
  <div class="modal" :class="{'is-active': active}"
       :style="{'z-index': current.type === 'loading' ? 40 : 20, 'overflow': current.type === 'loading' ? 'hidden': ''}">

    <div class="modal-background" v-if="current.type === 'loading'"
         style="background-color: rgba(255, 255, 255, 0.75)"></div>
    <div class="modal-background" v-else v-on:click="closeModal"></div>

    <record-add-view v-if="current.type === 'record_add'" :initial="current.props"></record-add-view>
    <record-edit-view v-else-if="current.type === 'record_edit'" :initial="current.props"></record-edit-view>
    <record-remove-view v-else-if="current.type === 'record_remove'" :record="current.props"></record-remove-view>

    <ip-pool-add v-else-if="current.type === 'ip_pool_add'" :attrs="current.props"></ip-pool-add>
    <ip-pool-remove v-else-if="current.type === 'ip_pool_remove'" :pool="current.props"></ip-pool-remove>

    <ip-reserve-view v-else-if="current.type === 'ip_reserve'" :ip="current.props"></ip-reserve-view>
    <ip-free-view v-else-if="current.type === 'ip_free'" :ip="current.props"></ip-free-view>
    <ip-edit-view v-else-if="current.type === 'ip_edit'" :ip="current.props"></ip-edit-view>

    <subnet-add v-else-if="current.type === 'subnet_add'" :attrs="current.props"></subnet-add>
    <ipblock-remove v-else-if="current.type === 'ipblock_remove'" :cidr="current.props"></ipblock-remove>

    <container-add v-else-if="current.type === 'container_add'" :attrs="current.props"></container-add>
    <delegation-add v-else-if="current.type === 'delegation_add'" :attrs="current.props"></delegation-add>

    <messages-view v-else-if="current.type === 'messages'" :config="current.props"></messages-view>

    <div class="modal-card" v-else-if="current.type === 'loading'">
      <section class="modal-content">
        <div style="text-align: center;">
          <img src="/static/images/spinner.gif" class="image is-64x64 is-inline-block">
          <h2 class="subtitle">Loading</h2>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
  import * as dnsZonesComponents from './dns-zones/components';
  import * as ipPoolsComponents from './ip-pools/components';
  import MessagesView from './MessagesView.vue';

  export default {
    name: 'modal-component',
    components: {
      'record-add-view': dnsZonesComponents.RecordAddView,
      'record-edit-view': dnsZonesComponents.RecordEditView,
      'record-remove-view': dnsZonesComponents.RecordRemoveView,
      'ip-pool-add': ipPoolsComponents.IpPoolAddView,
      'ip-pool-remove': ipPoolsComponents.IpPoolRemoveView,
      'ip-reserve-view': ipPoolsComponents.IpReserveView,
      'ip-free-view': ipPoolsComponents.IpFreeView,
      'ip-edit-view': ipPoolsComponents.IpEditView,
      'subnet-add': ipPoolsComponents.SubnetAddView,
      'ipblock-remove': ipPoolsComponents.IpBlockRemove,
      'container-add': ipPoolsComponents.ContainerAddView,
      'delegation-add': ipPoolsComponents.DelegationAddView,
      MessagesView
    },
    data () {
      return {
        queue: [{type: 'loading'}]
      };
    },
    computed: {
      active: function () {
        return this.queue ? this.queue.length > 0 : false;
      },
      current: function () {
        if (this.queue && this.queue.length > 0) {
          return this.queue[0];
        }
        return { type: '', props: '' };
      }
    },
    methods: {
      openModal (type, props) {
        this.queue.push({type: type, props: props});
      },
      closeModal () {
        if (this.current.type === 'loading') {
          while (this.current.type === 'loading') {
            this.queue.shift();
          }
        } else {
          this.queue.shift();
        }
      }
    },
    mounted () {
      this.$eventBus.$on('open_modal', this.openModal);
      this.$eventBus.$on('close_modal', this.closeModal);
    }
  };
</script>
