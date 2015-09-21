window.ActionBar = Backbone.View.extend({

  el: '.action-bar',

  events: {
    'click .action-bar__open-button': 'reveal',
    'click .action-bar__close-button': 'hide',
    'click .action-bar__expand-blurb': 'expandBlurb',
    'click .action-bar__collapse-blurb': 'collapseBlurb'
  },

  initialize: function() {
    if (!this.isMobile()) {
      this.makeSticky();
    }
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },

  hide: function() {
    this.$el.addClass('action-bar--mobile-view--closed').removeClass('action-bar--mobile-view--open');
  },

  reveal: function() {
    this.$el.removeClass('action-bar--mobile-view--closed').addClass('action-bar--mobile-view--open');
  },

  expandBlurb: function() {

  },

  collapseBlurb: function() {

  },

  makeSticky: function() {
    this.$el.sticky({topSpacing:0});
  }

});
