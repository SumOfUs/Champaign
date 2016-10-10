const Notification = Backbone.View.extend({

  OPEN_AFTER: 1, // seconds
  CLOSE_AFTER: 10, // seconds

  el: '.notification',

  events: {
    'click .notification__close': 'disappear',
  },

  initialize() {
    console.log(this.$el);
    window.setTimeout(this.appear.bind(this), this.OPEN_AFTER*1000);
    window.setTimeout(this.disappear.bind(this), this.CLOSE_AFTER*1000);
  },

  disappear() {
    this.$el.addClass('notification--hidden');
  },

  appear() {
    this.$el.removeClass('notification--hidden');
  },

});

module.exports = Notification;
