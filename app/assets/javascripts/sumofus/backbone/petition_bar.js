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
    this.initializeSticky();
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
    this.$el.addClass('petition-bar--mobile-view--closed').removeClass('petition-bar--mobile-view--open');
  },

  reveal: function() {
    this.$el.removeClass('petition-bar--mobile-view--closed').addClass('petition-bar--mobile-view--open');
  },

}));

module.exports = PetitionBar;
