const StickyMethods = require('sumofus/backbone/sticky_methods');
const FormMethods = require('sumofus/backbone/form_methods');

const ActionBar = Backbone.View.extend(_.extend(
  StickyMethods, FormMethods, {

  el: '.action-bar',

  events: {
    'click .action-bar__open-button': 'reveal',
    'click .action-bar__close-button': 'hide',
    'click .action-bar__expand-arrow': 'toggleBlurb',
    'click .action-bar__top': 'toggleBlurb',
    'click .action-bar__clear-form': 'clearForm',
    'ajax:success form.action': 'handleSuccess',
  },

  initialize: function() {
    this.petitionTextMinHeight = 120; // pixels
    this.checkBlurbHeight();
    this.initializeSticky();
    if (!this.isMobile()) {
      this.selectizeCountry();
    }
  },

  handleSuccess: function(e, data) {
    if (data.follow_up_url) {
      window.location.href = data.follow_up_url
    } else {
      // this should never happen, but just in case.
      alert("You've signed the petition! Thanks so much!");
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

  checkBlurbHeight: function (){
    if (this.$('.action-bar__top').outerHeight() > this.petitionTextMinHeight) {
      this.blurbIsTall = true;
    } else {
      this.blurbIsTall = false;
      this.$('.action-bar__expand-arrow').addClass('hidden-irrelevant');
    }
  },

  toggleBlurb: function() {
    if (this.blurbIsTall) {
      if (this.$('.action-bar__expand-arrow').hasClass('action-bar__expand-arrow--expanded')) {
        this.expandBlurb();
      } else {
        this.collapseBlurb();
      }
      this.$('.action-bar__expand-arrow').toggleClass('action-bar__expand-arrow--expanded');
    }
  },

  expandBlurb: function() {
    this.$('.action-bar__main').css('top', '');
    this.$el.parent('.sticky-wrapper').css('top', '');
  },

  collapseBlurb: function() {
    const height = this.$('.action-bar__top').outerHeight();
    this.$('.action-bar__main').css('top', `${height}px`);
    this.$el.parent('.sticky-wrapper').css('top', `-${height}px`);
  },

}));

module.exports = ActionBar;
