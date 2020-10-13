<template>
  <div id="reference-view">
    <div v-if="record">
      <span v-for="i in depth">&nbsp;</span>

      <label class="checkbox" v-if="edit && depth > 0">
        <input type="checkbox" name="references" v-model="checked">
      </label>
      <span class="icon has-icons-left" v-else-if="depth > 0">
        <i class="fa fa-minus"></i>
      </span>
      <span v-if="depth > 0">
        {{ record.name }} {{ record.type }} {{ record.value }}
        <span class="tags has-addons is-inline">
          <span class="tag is-link">{{ record.zone }}</span>
          <span class="tag">{{ record.view }}</span>
        </span>
      </span>

      <div v-if="graph[id].length > 0">
        <reference-view v-for="node in graph[id]" :key="node"
                        :id="node"
                        :records="records"
                        :graph="graph"
                        :edit="edit"
                        :depth="depth + 1"></reference-view>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'reference-view',
    props: ['records', 'graph', 'id', 'depth', 'edit'],
    data () {
      return {
        checked: false
      };
    },
    computed: {
      record: function () {
        for (let i = 0; i < this.records.length; i++) {
          if (this.records[i].id === this.id) {
            return this.records[i];
          }
        }
        return null;
      }
    },
    watch: {
      checked: function (newChecked, oldChecked) {
        if (oldChecked) {
          this.$eventBus.$emit('uncheck_reference', this.id);
        } else if (newChecked) {
          this.$eventBus.$emit('check_reference', this.id);
        }
      }
    }
  };
</script>
