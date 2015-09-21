window.ActionBar = Backbone.View.extend({

  el: '.action-bar',

  events: {
    'click .action-bar__open-button': 'reveal',
    'click .action-bar__close-button': 'hide',
    'click .action-bar__expand-blurb': 'expandBlurb',
    'click .action-bar__collapse-blurb': 'collapseBlurb'
  },

  initialize: function() {
    this.mobileWidth = 500;

    if (this.isMobile()) {
      this.initMobile();
    } else {
      this.makeSticky();
    }
  },

  initMobile: function() {
    this.$el.addClass('action-bar--mobile-view').addClass('action-bar--mobile-view--closed');
    this.$el.removeClass('action-bar--elevated');
    this.$('.action-bar__mobile-ui').removeClass('action-bar__mobile-ui--hidden');
  },

  isMobile: function() {
    return $(window).width() < this.mobileWidth;
  },

  hide: function() {
    this.$el.addClass('action-bar--mobile-view--closed').removeClass('action-bar--mobile-view--open');
  },

  reveal: function() {
    console.log("revealing", $el);
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
