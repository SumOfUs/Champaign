(function(){

  let ActivationToggle = Backbone.View.extend({

    events: {
      'ajax:before': 'updateState',
      'ajax:success': 'handleSuccess',
      'ajax:error': 'handleError',
      'click .toggle-button': 'handleClick',
    },

    initialize: function(){
      this.$stateInput = this.$('.activation-toggle-field');
    },

    handleClick: function(e){
      e.preventDefault();
      this.$el.submit();
      this.toggleButton();
    },

    toggleButton: function() {
      this.$('.toggle-button').toggleClass('btn-primary');
    },

    handleSuccess: function(e,data){},

    handleError: function(xhr, status, error){
      console.error('error', status, error);
      this.toggleButton();
    },

    updateState: function(){
      var state = !JSON.parse(this.$stateInput.val());
      this.$stateInput.val(state);
    },
  });

  const configureToggle = function() {
    $('form.activation-toggle').each(function(ii, el){
      let $el = $(el);
      if( $el.data('js-inited') != true) {
        let toggle = new ActivationToggle({ el: $el });
        $el.data('js-inited', true)
      }
    });
  }

  $.subscribe("activation:toggle", configureToggle);
}());

