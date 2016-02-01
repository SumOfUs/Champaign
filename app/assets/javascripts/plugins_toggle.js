const setupOnce = require('setup_once');

(function(){

  let ActivationToggle = Backbone.View.extend({

    events: {
      'ajax:before': 'updateState',
      'ajax:success': 'handleSuccess',
      'ajax:error': 'handleError',
      'change .onoffswitch__checkbox': 'handleClick',
    },

    initialize: function(){
      this.$stateInput = this.$('.activation-toggle-field');
      this.$checkbox = this.$('.onoffswitch__checkbox');
    },

    handleClick: function(e){
      this.$el.submit();
    },

    toggleButton: function() {
      this.$checkbox.prop("checked", !this.$checkbox.prop("checked"));
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

