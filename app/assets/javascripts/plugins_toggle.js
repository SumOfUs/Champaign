const setupOnce = require('setup_once');

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

  $.subscribe("activation:toggle", function(){
    setupOnce('form.activation-toggle', ActivationToggle);
  });
}());

