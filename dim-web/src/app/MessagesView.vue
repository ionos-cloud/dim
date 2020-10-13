<template>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title" v-if="config.error_messages">Error</p>
        <p class="modal-card-title" v-else-if="config.messages">Messages</p>
        <button class="delete" aria-label="close" v-on:click="closeModal"></button>
      </header>
      <section class="modal-card-body">
        <div class="notification is-danger" v-if="config.error_messages" v-for="error in config.error_messages">
          Code {{ error.code }}: {{ error.message }}
        </div>

        <div class="notification" v-if="config.messages" v-for="message in config.messages"
             :class="{'is-info': message[0] === 20, 'is-warning': message[0] === 30, 'is-danger': message[0] === 40}">
          {{ message[1] }}
        </div>

      </section>
      <footer class="modal-card-foot">
        <button class="button" v-on:click="closeModal">Close</button>
      </footer>
    </div>
</template>

<script>
  export default {
    name: 'messages-view',
    props: ['config'],
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
        if (this.config.refresh_event) {
          this.$nextTick(() => {
            this.$eventBus.$emit(this.config.refresh_event);
          });
        }
      }
    }
  };
</script>
