(function(){

  let SharesEditor = Backbone.View.extend({

    events: {
      'click .shares-editor__toggle-edit': 'toggleEditor',
    },

    initialize: function(){
      console.log('yooo')
      // this.$stateInput = this.$('.plugin-active-field');
    },

    toggleEditor: function(e) {
      console.log('hey',this.$(e.target).parents('tr'), this.$(e.target).parents('tr').next('.shares-editor__edit-row'))
      this.$(e.target).parents('tr').next('.shares-editor__edit-row').toggleClass('hidden-closed');
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
