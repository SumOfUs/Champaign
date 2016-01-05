const StickyMethods = require('sumofus/backbone/sticky_methods');
const FormMethods = require('sumofus/backbone/form_methods');

const PetitionBar = Backbone.View.extend(_.extend(
  StickyMethods, FormMethods, {

  el: '.petition-bar',

  events: {
    'click .petition-bar__open-button': 'reveal',
    'click .petition-bar__close-button': 'hide',
    'click .petition-bar__expand-arrow': 'toggleBlurb',
    'click .petition-bar__top': 'toggleBlurb',
    'click .petition-bar__clear-form': 'clearForm',
    'ajax:success form.action': 'handleSuccess',
  },

  initialize: function() {
    this.petitionTextMinHeight = 120; // pixels
    this.checkBlurbHeight();
    this.handleFormErrors();
    this.initializeSticky();
    this.guessLocation();
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
    this.$el.addClass('petition-bar--mobile-view--closed').removeClass('petition-bar--mobile-view--open');
  },

  reveal: function() {
    this.$el.removeClass('petition-bar--mobile-view--closed').addClass('petition-bar--mobile-view--open');
  },

  checkBlurbHeight: function (){
    if (this.$('.petition-bar__top').outerHeight() > this.petitionTextMinHeight) {
      this.blurbIsTall = true;
    } else {
      this.blurbIsTall = false;
      this.$('.petition-bar__expand-arrow').addClass('hidden-irrelevant');
    }
  },

  toggleBlurb: function() {
    if (this.blurbIsTall) {
      if (this.$('.petition-bar__expand-arrow').hasClass('petition-bar__expand-arrow--expanded')) {
        this.expandBlurb();
      } else {
        this.collapseBlurb();
      }
      this.$('.petition-bar__expand-arrow').toggleClass('petition-bar__expand-arrow--expanded');
    }
  },

  expandBlurb: function() {
    this.$('.petition-bar__main').css('top', '');
    this.$el.parent('.sticky-wrapper').css('top', '');
  },

  collapseBlurb: function() {
    const height = this.$('.petition-bar__top').outerHeight();
    this.$('.petition-bar__main').css('top', `${height}px`);
    this.$el.parent('.sticky-wrapper').css('top', `-${height}px`);
  },

}));

module.exports = PetitionBar;
