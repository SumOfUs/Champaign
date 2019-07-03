import Backbone from 'backbone';

const CampaignerOverlay = Backbone.View.extend({
  el: '.campaigner-overlay',

  events: {
    'click .campaigner-overlay__close': 'disappear',
    'ajax:success': 'togglePublish',
  },

  disappear() {
    this.$el.css('bottom', '-1000px');
    this.status = this.$el.data('status');
  },

  togglePublish() {
    const $field = this.$('.campaigner-overlay__publish-field');
    $field.val($field.val() == 'true' ? false : true);
    this.status = this.status === 'active' ? 'inactive' : 'active';
    this.$el.toggleClass('campaigner-overlay--active');
    this.$el.toggleClass('campaigner-overlay--inactive');
  },
});

export default CampaignerOverlay;
