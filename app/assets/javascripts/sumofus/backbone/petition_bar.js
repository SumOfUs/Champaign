const StickyMethods = require('sumofus/backbone/sticky_methods');
const FormMethods = require('sumofus/backbone/form_methods');

const PetitionBar = Backbone.View.extend(_.extend(
  StickyMethods, FormMethods, {

  el: '.petition-bar',

  events: {
    'click .petition-bar__close-button': 'hide',
    'click .petition-bar__clear-form': 'clearForm',
    'ajax:success form.action': 'handleSuccess',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    outstandingFields: the names of step 2 form fields that aren't satisfied by
  //      the values in the member hash.
  //    member: an object with fields that will prefill the form
  //    location: a hash of location values inferred from the user's request
  //    akid: the actionkitid (akid) to save with the user request
  //    thermometer: options to display on the thermometer
  initialize(options = {}) {
    this.petitionTextMinHeight = 120; // pixels
    this.handleFormErrors();
    this.initializePrefill(options);
    this.initializeSticky();
    this.updateThermometer(options.thermometer);
    this.policeHeights();
    this.followUpUrl = options.followUpUrl;
    if (!this.isMobile()) {
      this.selectizeCountry();
      $(window).on('resize', () => this.policeHeights());
    }
    this.insertActionKitId(options.akid);
    this.insertSource(options.source);
    $('.petition-bar__open-button').on('click', () => this.reveal());
  },

  initializePrefill(options) {
    if (this.formCanAutocomplete(options.outstandingFields, options.member)) {
      this.completePrefill(options.member, options.location);
      if (this.formFieldCount() > 0) {
        this.showFormClearer('petition', options.member);
      }
    } else {
      this.partialPrefill(options.member, options.location, options.outstandingFields);
    }
  },

  handleSuccess(e, data) {
    this.clearFormErrors();
    if (this.followUpUrl) {
      window.location.href = this.followUpUrl;
    } else {
      // this should never happen, but just in case.
      alert(I18n.t('petition.excited_confirmation'));
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

  policeHeights: function() {
    // move the blurb up into the correct position
    let topHeight = this.$('.petition-bar__top').outerHeight();
    if (this.isSticky){
      this.$el.parent('.sticky-wrapper').css('top', `-${topHeight}px`);
    } else if(!this.$el.hasClass('stuck-right')){
      this.$el.css('top', `-${topHeight}px`);
    }

    // make sure the title is in the write place if it wraps
    const $title = $('.petition-bar__title-bar');
    $title.css('top', `-${$title.outerHeight()}px`);

    // if the page is too short for the form, make it scroll overflow
    let maxHeight = window.innerHeight - topHeight;
    if(this.$el.hasClass('stuck-right')){
      maxHeight -= $title.outerHeight();
    }
    const overflow = (this.$('.petition-bar__main')[0].scrollHeight > maxHeight) ? 'scroll' : 'visible'
    this.$('.petition-bar__main').css('overflow', overflow);
    this.$('.petition-bar__main').css('max-height', `${maxHeight}px`);
  },

  updateThermometer: function(thermometer) {
    if(!_.isObject(thermometer) || _.keys(thermometer).length == 0) { return; }
    $('.thermometer__remaining').text(
      I18n.t('thermometer.signatures_until_goal',
      {goal: thermometer.goal_k, remaining: thermometer.remaining})
    );
    $('.thermometer__signatures').text(
      `${thermometer.signatures} ${I18n.t('thermometer.signatures')}`
    );
    $('.thermometer__mercury').css('width', `${thermometer.percentage}%`);
  }

}));

module.exports = PetitionBar;
