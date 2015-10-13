(function(){

  let PluginToggle = Backbone.View.extend({

    events: {
      'ajax:before': 'updateState',
      'ajax:success': 'handleSuccess',
      'ajax:error': 'handleError',
      'click .toggle-button': 'handleClick',
    },

    initialize: function(){
      this.$stateInput = this.$('.plugin-active-field');
    },

    handleClick: function(e){
      e.preventDefault();
      this.$el.submit();
      this.$('.toggle-button').removeClass('btn-primary');
      this.$(e.target).addClass('btn-primary');
    },

    handleSuccess: function(e,data){},

    handleError: function(xhr, status, error){
      console.log('error', status, error);
    },

    updateState: function(){
      var state = !JSON.parse(this.$stateInput.val());
      this.$stateInput.val(state);
    },
  });

  const configureToggle = function() {
    $('form.plugin-toggle').each(function(ii, el){
      let toggle = new PluginToggle({ el: $(el) });
    });
  }

  $.subscribe("plugins:toggle", configureToggle);
}());

