<template>
  <section class="hero is-medium">
    <div class="hero-body">
      <div class="container">
        <h1 class="title">
          Oops! Error 404
        </h1>
        <h2 class="subtitle">We can't seem to find the page you're looking for.</h2>
        <router-link class="button is-link" :to="{name: 'zones-list'}" exact>
          Go home
        </router-link>
      </div>
    </div>
  </section>
</template>

<script>
  export default {
    name: 'not-found',
    mounted () {
      this.$eventBus.$emit('hide_search');
    },
    beforeDestroy () {
      this.$eventBus.$emit('show_search');
    }
  };
</script>
