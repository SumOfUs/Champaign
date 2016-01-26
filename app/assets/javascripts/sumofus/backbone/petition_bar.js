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

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    outstandingFields: the names of step 2 form fields that can't be prefilled
  //    member: an object with fields that will prefill the form
  initialize(options = {}) {
    this.petitionTextMinHeight = 120; // pixels
    this.handleFormErrors();
    this.initializePrefill(options);
    this.expandBlurb();
    this.followUpUrl = options.followUpUrl;
    this.initializeSticky();
    if (!this.isMobile()) {
      this.selectizeCountry();
    }
  },

  initializePrefill(options) {
    if (this.formCanAutocomplete(options.outstandingFields, options.member)) {
      this.completePrefill(options.member);
      if (this.formFieldCount() > 0) {
        this.showFormClearer('petition', options.member);
      }
    } else {
      this.partialPrefill(options.member, options.outstandingFields);
    }
  },

  handleSuccess(e, data) {
    this.clearFormErrors();
    if (this.followUpUrl) {
      window.location.href = this.followUpUrl;
    } else {
      // this should never happen, but just in case.
      alert(I18n.t('petition.confirmation')+'!');
    }
  },

  isMobile() {
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
