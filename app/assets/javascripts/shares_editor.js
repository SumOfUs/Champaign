(function(){

  let SharesEditor = Backbone.View.extend({

    events: {
      'click tr.shares-editor__summary-row': 'toggleEditor',
      'click .shares-editor__new-type-toggle .btn': 'switchVariantForm',
      'submit .shares-editor__new-form': 'newShareSubmitted',
    },

    initialize: function(){
      this.openEditorForErrors();
      // this.$stateInput = this.$('.plugin-active-field');
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
      e.preventDefault();
      let $target = $(e.target);
      let $edit_row = $('<tr class="shares-editor__edit-row"><td colspan="5"></td></tr>')
      $edit_row.find('td').append($target.clone().addClass('one-form'));
      this.$('.shares-editor__existing tbody').append($edit_row);
      console.log("submitted new form",$target.serializeArray());
    },

    openEditorForErrors: function(){
      $.subscribe('page:errors', (e) => {
        this.openEditor(this.$('.has-error').parents('.shares-editor__edit-row'));
      });
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
