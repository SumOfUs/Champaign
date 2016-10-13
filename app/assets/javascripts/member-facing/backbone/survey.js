let ErrorDisplay = require('shared/show_errors');
let MobileCheck = require('member-facing/backbone/mobile_check');
const GlobalEvents = require('shared/global_events');

const Survey = Backbone.View.extend({

  el: '.survey',
  HIDDEN_FIELDS: ['source', 'referrer_id'],

  events: {
    'click .survey__skip-button': 'skipSection',
    'ajax:success form.survey__form': 'handleSuccess',
    'ajax:error form.survey__form': 'handleFailure',
    'ajax:send form.survey__form': 'handleSend',
  },

  // options: object with any of the following keys
  //    source: the referring source to save
  //    referrer_id: the champaign id of the referrer
  //    member: an object with fields that will prefill the form
  //    location: a hash of location values inferred from the user's request
  //    followUpUrl: the url to redirect to after the survey is completed
  initialize(options={}) {
    if (!MobileCheck.isMobile()) {
      this.selectizeCountry();
    }
    this.prefill(_.extend(options.location, options.member));
    this.revealFirstForm();
    this.followUpUrl = options.followUpUrl;
    // this.$submitButton = this.$('.action-form__submit-button');
    // this.buttonText = this.$submitButton.text();
    GlobalEvents.bindEvents(this);
    this.forms
  },

  revealFirstForm() {
    this.$('.survey__form').first().removeClass('hidden-closed');
  },

  selectizeCountry() {
    this.$('.action-form__country-selector').selectize();
  },

  // prefillValues - an object mapping form names to prefill values
  prefill(prefillValues) {
    if(!_.isObject(prefillValues)) { return; }
    this.$('.survey__form input, select').each((ii, field) => {
      let $field = $(field);
      let name = $field.prop('name');
      if (prefillValues.hasOwnProperty(name)) {
        $field.val(prefillValues[name]);
      }
    });
  },

  insertHiddenFields(options) {
    for(var ii = 0; ii < this.HIDDEN_FIELDS.length; ii++) {
      let field = this.HIDDEN_FIELDS[ii];
      if(options[field] && this.$el) {
        this.insertHiddenInput(field, options[field], this.$el);
      }
    }
  },

  insertHiddenInput(name, value, element) {
    $('<input>').attr({
      type: 'hidden',
      name: name,
      value: value
    }).appendTo(element);
  },

  handleSuccess(e, data){
    ErrorDisplay.clearErrors(this.$(e.target));
    this.enableButton(e);
    this.followForm(this.$(e.target));
  },

  handleFailure(e, data) {
    ErrorDisplay.clearErrors(this.$(e.target));
    ErrorDisplay.show(e, data);
    this.enableButton(e);
  },

  handleSend(e) {
    ErrorDisplay.clearErrors(this.$(e.target));
    this.disableButton(e);
  },

  // we assume all sections are skippable, since required sections should
  // not have a visible skip button
  skipSection(e) {
    this.followForm(this.$(e.target).parents('.survey__form'));
  },

  followForm($form) {
    const $nextForm = $form.next('.survey__form');
    if ($nextForm.length) {
      this.revealForm($nextForm);
    } else {
      this.followUp();
    }
  },

  revealForm($form) {
    $form.removeClass('hidden-closed');
    $('html, body').animate({ scrollTop: $form.offset().top }, 500);
  },

  followUp() {
    if (this.followUpUrl) {
      this.redirectTo(this.followUpUrl);
    } else {
      window.alert('Thanks for completing our survey!');
    }
  },

  redirectTo(url) {
    window.location.href = url
  },

  disableButton(e) {
    this.$(e.target).find('.survey__button').each((ii, el) => {
      let $btn = this.$(el);
      if ($btn.data('enabled-text') === undefined) {
        $btn.data('enabled-text', $btn.text());
      }
      $btn.text(I18n.t('form.processing'))
      $btn.addClass('button--disabled');
    });
  },

  enableButton(e) {
    this.$(e.target).find('.survey__button').each((ii, el) => {
      let $btn = this.$(el);
      $btn.text($btn.data('enabled-text'));
      $btn.removeClass('button--disabled');
    });
  },
});

module.exports = Survey;
