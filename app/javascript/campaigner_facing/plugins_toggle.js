import setupOnce from './setup_once';

(function() {
  let ActivationToggle = Backbone.View.extend({
    events: {
      'ajax:before': 'toggleState',
      'ajax:success': 'handleSuccess',
      'ajax:error': 'handleError',
      'change .onoffswitch__checkbox': 'handleClick',
    },

    initialize: function() {
      this.$stateInput = this.$('.activation-toggle-field');
      this.$checkbox = this.$('.onoffswitch__checkbox');
      this.state = this.$stateInput.val();
    },

    handleClick: function(e) {
      if (
        this.state == 'published' &&
        this.$stateInput.data('confirm-turning-off')
      ) {
        if (!window.confirm(this.$stateInput.data('confirm-turning-off'))) {
          this.toggleButton();
          return false;
        }
      }
      this.$el.submit();
    },

    toggleButton: function() {
      this.$checkbox.prop('checked', !this.$checkbox.prop('checked'));
    },

    handleSuccess: function(e, data) {},

    handleError: function(xhr, status, error) {
      console.error('error', status, error);
      this.toggleButton();
      this.toggleState();
    },

    toggleState: function(e) {
      if (
        $(e.target)
          .find('input.onoffswitch__checkbox')
          .hasClass('use-publish-states')
      ) {
        this.state = this.state === 'published' ? 'unpublished' : 'published';
      } else {
        this.state = this.state === 'true' ? 'false' : 'true';
      }
      this.$stateInput.val(this.state);
    },
  });

  $.subscribe('activation:toggle', function() {
    setupOnce('form.activation-toggle', ActivationToggle);
  });
})();
