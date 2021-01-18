import axios from 'axios';
import configs from '../config/api.env';
import Vue from 'vue';

axios.defaults.withCredentials = true;

let rpc = Vue.mixin({
  methods: {
    sleep: function (ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    },
    jsonRpc: async function (method, params, successCallback, loading) {
      if (loading) {
        this.$eventBus.$emit('open_modal', 'loading');
      }
      await this.sleep(configs.SLEEP);
      axios.post(configs.DIM_RPC, {
        id: null,
        jsonrpc: '2.0',
        method: method,
        params: params
      })
        .then((response) => {
          if (loading) {
            this.$eventBus.$emit('close_modal');
          }
          successCallback(response);
        })
        .catch((error) => {
          if (loading) {
            this.$eventBus.$emit('close_modal');
          }
          let errors = {
            403: 'You do not have enough rights to perform this action.',
            500: 'DIM backend has encountered an error.'
          };
          let message = '';
          if (errors.hasOwnProperty(error.response.status)) {
            message = errors[error.response.status];
          } else {
            message = 'An unknown error has occured.';
          }
          this.$eventBus.$emit('open_modal', 'messages', {error_messages: [{code: error.response.status, message: message}]});
        });
    },
    loginRpc: function (loginArgs, successCallback) {
      axios.post(configs.DIM_LOGIN, loginArgs,
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        }
      ).then((response) => {
        successCallback(response);
      }).catch(() => {
        console.log('No cookie received from DIM');
      });
    }
  }
});

export default rpc;
