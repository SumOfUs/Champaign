(function(){

  let SharesEditor = Backbone.View.extend({

    events: {
      'click tr.shares-editor__summary-row': 'toggleEditor',
      'click .shares-editor__new-type-toggle .btn': 'switchVariantForm',
      'ajax:success form.shares-editor__new-form': 'clearForm',
    },

    initialize: function(){
      $.subscribe('page:errors', this.openEditorForErrors());
      $.subscribe('page:saved', this.updateSummaryRows());

      // this is the kind of DOM hosuekeeping that makes me want to use react
      $.subscribe('image:success', this.addImageSelectors());
      $.subscribe('image:destroyed', this.pruneImageSelectors());
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

    clearForm: function(e){
      $(e.target).find('input[type="text"], textarea').val('')
    },

    openEditorForErrors: function(){
      return () => { // closure for this in callback
        this.openEditor(this.$('.has-error').parents('.shares-editor__edit-row'));
      }
    },

    updateSummaryRows: function(){
      return (e, data) => { // closure for `this` in callback
        $.get(`/api/pages/${data.id}/share-rows`, (rows) => {
          _.each(rows, (row) => {
            let $row = $(row.html);
            $row = $(`#${$row.prop('id')}`).replaceWith($row);
            $row = $(`#${$row.prop('id')}`);
            if (!$row.next('.shares-editor__edit-row').hasClass('hidden-closed')) {
              $row.find('.shares-editor__toggle-edit').text('Done');
            }
          })
        });
      }
    },

    addImageSelectors: function(){
      return (e, file, id, html) => { // closure for `this` in callback
        let newOption = `<option value='${id}'>${file.name}</option>`;
        this.$('.shares-editor__image-selector').append(newOption);
      }
    },

    pruneImageSelectors: function(){
      return (e, id) => { // closure for `this` in callback
        this.$(`option[value="${id}"]`).remove()
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
