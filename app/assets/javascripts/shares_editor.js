(function(){

  let SharesEditor = Backbone.View.extend({

    events: {
      'click tr.shares-editor__summary-row': 'toggleEditor',
      'click .shares-editor__new-type-toggle .btn': 'switchVariantForm',
      'submit .shares-editor__new-form': 'newShareSubmitted'
    },

    initialize: function(){
      $.subscribe('page:errors', this.openEditorForErrors());
      $.subscribe('page:saved', this.newShareSaved());
    },

    toggleEditor: function(e) {
      let $target = this.$(e.target);
      $target = $target.is('tr') ? $target : $target.parents('tr');
      let $btn = $target.find('.shares-editor__toggle-edit');
      $target.next('.shares-editor__edit-row').toggleClass('hidden-closed');
      $btn.text( $btn.text() == "Edit" ? "Done" : "Edit" );
    },

    openEditor: function($edit_row){
      let $prev = $edit_row.prev('.shares-editor__summary-row');
      let $btn = $prev.find('.shares-editor__toggle-edit');
      $btn.text( "Done" );
      $edit_row.removeClass('hidden-closed');
    },

    switchVariantForm: function(e){
      let $target = this.$(e.target)
      const desired = $target.data('state');
      if (desired) {
        this.$('.shares-editor__new-type-toggle .btn').removeClass('btn-primary');
        $target.addClass('btn-primary');
        this.$('.shares-editor__new-form').addClass('hidden-closed');
        this.$(`.shares-editor__new-form[data-share="${desired}"]`).removeClass('hidden-closed');
      }
    },

    newShareSubmitted: function(e) {
      // this works ok, but new plan is to just pass the html for the new rows down after
      // the form clears validation cause its counter intuitive if it becomes a table row
      // and then gets validation errors.
      e.preventDefault();
      let $form = $(e.target);
      $form.find('input[type="text"], textarea').each(function(ii, el) {
        $(el).attr('value', $(el).val());
      });
      let $edit_row = $('<tr class="shares-editor__edit-row"><td colspan="5"></td></tr>')
      let $new_form = $form.clone().addClass('one-form');
      let tempid_regex = new RegExp($form.data('tempid'), 'g');
      let new_tempid = Math.random().toString().slice(2,11);
      $new_form.find('input[type="submit"]').remove();
      $edit_row.find('td').append($new_form);
      this.$('.shares-editor__existing tbody').append($edit_row);
      this.clearForm($form);
      $new_form.parent().html( $new_form.parent().html().replace( tempid_regex, new_tempid ) );
      console.log("submitted new form",$form.serializeArray());
    },

    clearForm: function($form){
      $form.find('input[type="text"], textarea').val('')
    },

    openEditorForErrors: function(){
      () => { // closure for this in callback
        this.openEditor(this.$('.has-error').parents('.shares-editor__edit-row'));
      }
    },

    newShareSaved: function(){
      return (e, data) => { // closure for this in callback
        if (data.new_shares && _.keys(data.new_shares).length > 0){
          _.mapObject(data.new_shares, (new_id, name) => {
            $form = this.$(`[data-type="${name}"]`);
            $form.append(`<input type="hidden" value="${new_id}" name="${name}[id]" id="${name}_id">`);
            return new_id;
          });
        }
      }
    },

  });

  const configureShares = function() {
    $('.shares-editor').each(function(ii, el){
      let $el = $(el);
      if( $el.data('js-inited') != true) {
        let editor = new SharesEditor({ el: $el });
        $el.data('js-inited', true)
      }
    });
  }

  $.subscribe("shares:edit", configureShares);
}());
