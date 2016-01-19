const StickyMethods = require('sumofus/backbone/sticky_methods');
const FormMethods = require('sumofus/backbone/form_methods');

const PetitionBar = Backbone.View.extend(_.extend(
  StickyMethods, FormMethods, {

  el: '.petition-bar',

  events: {
    'click .petition-bar__open-button': 'reveal',
    'click .petition-bar__close-button': 'hide',
    'click .petition-bar__clear-form': 'clearForm',
    'ajax:success form.action': 'handleSuccess',
  },

  initialize: function() {
    this.petitionTextMinHeight = 120; // pixels
    this.handleFormErrors();
    this.expandBlurb();
    if (!this.$el.hasClass('stuck-right')){
      this.initializeSticky();
    }
    if (!this.isMobile()) {
      this.selectizeCountry();
    }
  },

  handleSuccess: function(e, data) {
    this.clearFormErrors();
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
    this.$('.petition-bar__mobile-view')
      .addClass('petition-bar__mobile-view--closed')
      .removeClass('petition-bar__mobile-view--open');
  },

  reveal: function() {
    this.$('.petition-bar__mobile-view')
      .removeClass('petition-bar__mobile-view--closed')
      .addClass('petition-bar__mobile-view--open');
  },

  expandBlurb: function() {
    const height = this.$('.petition-bar__top').outerHeight();
    if (this.isSticky){
      this.$el.parent('.sticky-wrapper').css('top', `-${height}px`);
    } else if(!this.$el.hasClass('stuck-right')){
      this.$el.css('top', `-${height}px`);
    }
  },

}));

module.exports = PetitionBar;
