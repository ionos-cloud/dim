<template>
  <div id="app">
    <nav class="navbar is-link is-fixed-top" role="navigation" aria-label="main navigation">
      <div class="navbar-brand">
        <span class="navbar-item navbar-text">
          DIM
        </span>
        <button class="button navbar-burger" data-target="navbar-menu">
          <span></span>
          <span></span>
          <span></span>
        </button>
      </div>

      <div class="navbar-menu" id="navbar-menu">
        <div class="navbar-start">
          <router-link class="navbar-item" :to="{name: 'zones-list'}">
            DNS zones
          </router-link>
          <router-link class="navbar-item" :to="{name: 'pools-list'}">
            IP Pools
          </router-link>
          <router-link class="navbar-item" :to="{name: 'ip-spaces'}">
            IP Space
          </router-link>
        </div>

        <div class="navbar-end">
          <div class="navbar-item" v-show="show_search">
            <p class="control has-icons-left">
              <input class="input is-small" type="text" placeholder="Search" v-model="pattern"
                     v-on:keyup.enter="search">
              <span class="icon is-small is-left">
                <i class="fa fa-search"></i>
              </span>
            </p>
          </div>
          <div class="navbar-item has-dropdown is-hoverable">
            <a class="navbar-link">
              {{ full_name }}
            </a>

            <div class="navbar-dropdown">
              <a class="navbar-item" :href="$config.LOGOUT" v-on:click.stop="cleanCookies">
                <span class="icon is-small is-left">
                  <i class="fa fa-sign-out"></i>
                </span> Logout
              </a>
            </div>
          </div>
        </div>
      </div>
    </nav>
    <router-view :key="full_name" :rights="perms.rights">
      <div class="container is-fluid">You are not authenticated. Please login.</div>
    </router-view>
    <div id="modals">
      <modal-view></modal-view>
    </div>
  </div>
</template>
<script>
  import ModalView from './ModalView.vue';

  export default {
    name: 'app',
    components: {
      'modal-view': ModalView
    },
    data () {
      return {
        full_name: '',
        login_args: this.$cookies.get('LOGIN_ARGS') ? this.$cookies.get('LOGIN_ARGS').replace(/"/g, '') : '',
        show_search: true,
        pattern: '',
        perms: '',
        user: ''
      };
    },
    computed: {
      username: function () {
        let params = new URLSearchParams(this.login_args);
        return params.get('username');
      }
    },
    methods: {
      cleanCookies (event) {
        this.$cookies.remove('FULL_NAME');
        this.$cookies.remove('LOGIN_ARGS');
      },
      search () {
        this.$eventBus.$emit('search', this.pattern);
      },
      cleanUpSearch () {
        this.pattern = '';
      },
      showSearch () {
        this.show_search = true;
      },
      hideSearch () {
        this.show_search = false;
      },
      getUserRights () {
        this.jsonRpc('user_get_rights', [this.username], (response) => {
          this.perms = response.data.result;
        });
      },
      decodeFlaskCookie (val) {
        if (val.indexOf('\\') === -1) {
          return val;  // not encoded
        }
        val = val.slice(1, -1).replace(/\\"/g, '"');
        val = val.replace(/\\(\d{3})/g, function (match, octal) {
          return String.fromCharCode(parseInt(octal, 8));
        });
        return val.replace(/\\\\/g, '\\');
      }
    },
    beforeMount () {
      if (!this.login_args) {
        this.$cookies.set('REDIRECT', this.$route.fullPath, '1d', '/');
        window.location = this.$config.LOGIN;
      } else if (!this.user) {
        this.loginRpc(this.login_args, (response) => {
          this.getUserRights();
          if (this.$cookies.get('REDIRECT')) {
            let path = this.$cookies.get('REDIRECT');
            this.$cookies.remove('REDIRECT');
            this.$router.push(path);
          }
        });
      }
      this.$eventBus.$on('empty_search', this.cleanUpSearch);
      this.$eventBus.$on('show_search', this.showSearch);
      this.$eventBus.$on('hide_search', this.hideSearch);
    },
    mounted () {
      this.$eventBus.$emit('open_modal', 'loading');
      if (this.$cookies.isKey('FULL_NAME')) {
        this.full_name = this.decodeFlaskCookie(this.$cookies.get('FULL_NAME'));
      }
    }
  };
</script>
