<template>
  <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Edit IP: {{ ip }}</p>
      <button class="delete" aria-label="close" v-on:click="closeModal"></button>
    </header>
    <section class="modal-card-body">
      <a class="is-pulled-right" v-on:click="showTable = !showTable">
          <span class="icon has-icons-left">
            <i class="fa fa-chevron-down"></i>
          </span>
        details
      </a>
      <br><br>

      <table class="table is-fullwidth" v-show="showTable">
        <tbody>
        <tr v-for="(value, key) in details">
          <th class="is-capitalized">{{ key }}</th>
          <td>{{ value }}</td>
        </tr>
        </tbody>
      </table>

      <div class="field">
        <label class="label has-text-weight-semibold">
          PTR
        </label>
        <div class="control has-icons-left">
          <input class="input" name="ptr_target" v-model="attrs.ptr_target">
          <span class="icon is-small is-left">
              <i class="fa fa-pencil"></i>
            </span>
        </div>
      </div>

      <div class="field">
        <label class="label has-text-weight-semibold">Comment</label>
        <div class="control">
          <textarea class="textarea" name="comment" v-model="attrs.comment" maxlength="255"></textarea>
        </div>
      </div>

    </section>
    <footer class="modal-card-foot columns">
      <div class="column is-full">
        <button class="button" v-on:click="closeModal">Cancel</button>
        <button class="button is-danger is-pulled-right" v-on:click="editIp">
          Save IP
        </button>
      </div>
    </footer>
  </div>

</template>

<script>
  export default {
    name: 'ip-edit-view',
    props: ['ip'],
    data () {
      return {
        details: {},
        showTable: false,
        attrs: {
          comment: '',
          ptr_target: ''
        }
      };
    },
    methods: {
      closeModal () {
        this.$eventBus.$emit('close_modal');
      },
      editIp () {
        this.closeModal();
        //  find record by ip with type ptr 1/0
        //  find id by references with record
        //  rr_edit -> change content

        var rrFindIdParams = {};
        var rrEditParams = {};
        var rrEditID;

        rrFindIdParams.ip = this.ip;
        rrFindIdParams.type = 'PTR';
        rrFindIdParams.name = this.details.ptr_target;
        rrFindIdParams.delete = 'False';
        rrEditParams.ptrdname = this.attrs.ptr_target;
        rrEditParams.views = [];
        this.jsonRpc('rr_get_references', [rrFindIdParams],
          (response) => {
            if (response === '') {
              console.log('Error');
            } else {
              rrEditID = response.data.result.root;
              response.data.result.records.forEach(function (record) {
                if (record.id === rrEditID) {
                  rrEditParams.views.push(record.view);
                }
              });
              this.jsonRpc('rr_edit', [rrEditID, rrEditParams],
                (response) => {
                  this.$eventBus.$emit('refresh_ips');
                }
              );
            }
          });
      }
    },
    mounted () {
      this.jsonRpc('ipblock_get_attrs', [this.ip, {host: true, layer3domain: this.$config.DEFAULT_LAYER3DOMAIN}],
        (response) => {
          if (response.data.result) {
            this.details = response.data.result;
            this.attrs.comment = response.data.result.comment;
            this.attrs.ptr_target = response.data.result.ptr_target;
          }
        }
      );
    }
  };
</script>
