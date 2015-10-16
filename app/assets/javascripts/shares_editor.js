(function(){

  let SharesEditor = Backbone.View.extend({

    events: {
      'click tr.shares-editor__summary-row': 'toggleEditor',
    },

    initialize: function(){
      console.log('yooo')
      // this.$stateInput = this.$('.plugin-active-field');
    },

    toggleEditor: function(e) {
      let $target = this.$(e.target);
      $target = $target.is('tr') ? $target : $target.parents('tr');
      let $btn = $target.find('.shares-editor__toggle-edit');
      $target.next('.shares-editor__edit-row').toggleClass('hidden-closed');
      $btn.text( $btn.text() == "Edit" ? "Done" : "Edit" );
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
