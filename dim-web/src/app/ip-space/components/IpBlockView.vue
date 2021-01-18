<template>
  <div id="ip-block-view">
    <span>

      <span v-if="!ipblock">
        IPv{{ ipversion }}
      </span>
      <span v-else>
        <span v-if="getIcon() !== ''">
          <span class="radio" v-if="show_delete" v-on:click="removeIPblock">
            <input type="radio" name="ipblock"/>
          </span>
          <span v-for="i in depth - 1">&nbsp;&nbsp;</span>

          <span class="icon has-icons-left has-text-link pointer" v-on:click="toggleDirection">
            <i :class="'fa fa-angle-' + direction"></i>
          </span>
          <span class="icon has-icons-left has-text-link">
            <i :class="'fa fa-'+ getIcon()"></i>
          </span>
          <span  v-on:click="toggleDirection" class="pointer"
                 :class="{'tooltip is-tooltip-info is-tooltip-right': getAttributes()}"
                 :data-tooltip="getAttributes()">
            {{ ipblock.ip }}
          </span>
        </span>
        <span v-else>
          <span v-for="i in depth">&nbsp;&nbsp;</span>
          <span :class="{
          'has-text-danger': ipblock.status === 'Static' && this.parent !== null && this.parent.status === 'Container',
          'has-text-grey-light pointer': ipblock.status === 'Available' && ipblock.number && can_network_admin,
          'has-text-grey-light': ipblock.status === 'Available',
          'has-text-link': ipblock.status === 'Static',
          'has-text-success': ipblock.status === 'Reserved'}">
            &nbsp; &nbsp; &nbsp; &nbsp;
            <span v-if="ipblock.number && can_network_admin" v-on:click="createSubnet">{{ ipblock.number }} addresses </span>
            <span v-else-if="ipblock.number">{{ ipblock.number }} addresses </span>
            <span v-else :class="{'tooltip is-tooltip-info is-tooltip-right': getAttributes()}"
                  :data-tooltip="getAttributes()">{{ ipblock.ip }}</span>
          </span>
        </span>
      </span>
    </span>

    <ip-block-view v-if="children.length > 0" v-for="child in children" :key="child.id"
                   :parent="ipblock"
                   :ipversion="ipversion"
                   :ipblock="child"
                   :statuses="statuses"
                   :types="types"
                   :attributes="attributes"
                   :can_network_admin="can_network_admin"
                   :show_delete="show_delete"
                   :depth="depth + 1">
    </ip-block-view>
  </div>
</template>

<script>
  export default {
    name: 'ip-block-view',
    props: ['ipversion', 'ipblock', 'statuses', 'types', 'attributes', 'depth', 'parent', 'can_network_admin', 'show_delete'],
    data () {
      return {
        children: [],
        direction: 'down'
      };
    },
    methods: {
      getIcon () {
        if (this.ipblock.status === 'Container') {
          return 'archive';
        } else if (this.ipblock.status === 'Subnet') {
          return 'sitemap';
        } else if (this.ipblock.status === 'Delegation') {
          return 'cube';
        }
        return '';
      },
      toggleDirection () {
        if (this.direction === 'down') {
          this.updateChildren();
        } else {
          this.direction = 'down';
          this.children = [];
        }
      },
      shouldDisplayChild (child) {
        if (this.statuses.indexOf('Unmanaged') !== -1) {
          return true;
        }
        if (this.ipblock) {
          return true;
        }
        return ['Container', 'Subnet', 'Delegation'].indexOf(child.status) !== -1;
      },
      updateChildren () {
        let params = {
          ipversion: this.ipversion,
          status: this.types.concat(this.statuses),
          layer3domain: this.$config.DEFAULT_LAYER3DOMAIN
        };
        if (this.attributes.length > 0) {
          params.attributes = this.attributes;
          params.include_attributes = true;
        }
        if (this.ipblock) {
          params.ipblock = this.ipblock.ip;
        }
        this.jsonRpc('ipblock_list', [params], (response) => {
          if (response.data.result) {
            this.direction = 'up';
            for (let i = 0; i < response.data.result.length; i++) {
              let child = response.data.result[i];
              if (this.shouldDisplayChild(child)) {
                this.children.push(child);
              }
            }
          }
        }, true);
      },
      refreshTree () {
        if (!this.ipblock) {
          this.children = [];
          this.updateChildren();
        }
      },
      createSubnet () {
        this.$eventBus.$emit('open_modal', 'subnet_add', {cidr: this.ipblock.ip, gateway: this.ipblock.ip, createPool: true});
      },
      removeIPblock () {
        this.$eventBus.$emit('tree_radio', this.ipblock.ip);
      },
      getAttributes () {
        if (!this.ipblock.attributes) {
          return false;
        }
        let result = '';
        for (let key in this.ipblock.attributes) {
          result += key + ' = ' + this.ipblock.attributes[key];
        }
        return result;
      }
    },
    mounted () {
      this.$eventBus.$on('refresh_tree', this.refreshTree);
    }
  };
</script>
