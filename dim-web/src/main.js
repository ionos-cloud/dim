// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue';
import { App } from './app';
import router from './router';

import 'bulma/css/bulma.css';
import 'bulma-extensions/bulma-tooltip/dist/bulma-tooltip.min.css';
import VueCookies from 'vue-cookies';
import VueConfig from 'vue-config';
import VeeValidate from 'vee-validate';
import configs from '../config/api.env.js';
import moment from 'moment';
import vSelect from 'vue-select/src/components/Select.vue';
import rpc from './rpc';

Vue.use(VueCookies);
Vue.use(VueConfig, configs);
Vue.use(VeeValidate);
Vue.component('v-select', vSelect);

Vue.filter('formatDate', function (value) {
  if (value) {
    return moment(String(value)).format('DD-MM-YYYY hh:mm:ss');
  }
});

VeeValidate.Validator.extend('unique-keys', {
  getMessage (field) {
    return 'The options keys must be unique.';
  },
  validate (value) {
    return (new Set(value)).size === value.length;
  }
});

Vue.prototype.$eventBus = new Vue();

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  template: '<App/>',
  components: { App },
  mixins: [ rpc ]
});
