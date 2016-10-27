let ErrorDisplay = require('shared/show_errors');
let MobileCheck = require('member-facing/backbone/mobile_check');
const GlobalEvents = require('shared/global_events');

const Survey = Backbone.View.extend({

  el: '.survey',
  HIDDEN_FIELDS: ['source', 'referrer_id'],
  DEFAULT_SCROLL_OFFSET: 80,

  events: {
    'click .survey__skip-button': 'skipSection',
    'ajax:success form.survey__form': 'handleSuccess',
    'ajax:error form.survey__form': 'handleFailure',
    'ajax:send form.survey__form': 'handleSend',
  },

  // options: object with any of the following keys
  //    source: the referring source to save
  //    referrer_id: the champaign id of the referrer
  //    prefill: an object with fields that will prefill the form
  //    followUpUrl: the url to redirect to after the survey is completed
  //    scrollOffset: the gap to leave between the top of the browser
  //      window and the start of a form when scrolling down. default is 80
  initialize(options={}) {
    let hasScrollOffset = options.hasOwnProperty('scrollOffset');
    this.scrollOffset = hasScrollOffset ? options.scrollOffset : this.DEFAULT_SCROLL_OFFSET;
    this.$forms = this.$('.survey__form');
    this.insertHiddenFields(options);
    this.prefill(options.prefill);
    this.revealFirstForm();
    this.submitFirstFormIfComplete();
    this.followUpUrl = options.followUpUrl;
    if (!MobileCheck.isMobile()) {
      this.selectizeCountry();
    }
    GlobalEvents.bindEvents(this);
  },

  revealFirstForm() {
    this.$('.survey__form').first().removeClass('hidden-closed');
  },

  selectizeCountry() {
    this.$('.action-form__country-selector').selectize();
  },

  // prefillValues - an object mapping form names to prefill values
  prefill(prefillValues) {
    this.prefillValues = prefillValues;
    if(!_.isObject(prefillValues)) { return; }
    this.$('.survey__form input, select').each((ii, field) => {
      let $field = $(field);
      let name = $field.prop('name');
      if (prefillValues.hasOwnProperty(name)) {
        let radioOrCheck = ($field.prop('type') === 'radio' || $field.prop('type') === 'checkbox');
        if (radioOrCheck && $field.val() == prefillValues[name]) {
          $field.prop('checked', 'checked');
        } else {
          $field.val(prefillValues[name]);
        }
      }
    });
  },

  submitFirstFormIfComplete() {
    // form.serialize() returns the forms values as URL encoded params,
    // so `=&` only happens when there's a blank value in the form, eg
    // name=&weight=180, and `=` at the end means the last param is blank
    let $form = this.$forms.first();
    let serialized = $form.serialize();
    let noneEmpty = (serialized.indexOf('=&') === -1 && serialized.slice(-1) !== '=');
    let allPresent = _.every($form.find('input, select'), (el) => {
      if (this.$(el).prop('type') === 'hidden') return true;
      let name = this.$(el).prop('name');
      let outputIncludesName = (serialized.indexOf(`&${name}=`) !== -1 ||
                                serialized.indexOf(`${name}=`) === -0);
      let prefillIncludesName = (this.prefillValues[name] !== undefined);
      return outputIncludesName && prefillIncludesName;
    });
    if (noneEmpty && allPresent) $form.submit();
  },

  insertHiddenFields(options) {
    for(var field of this.HIDDEN_FIELDS) {
      if(options[field] && this.$el) {
        this.insertHiddenInput(field, options[field], this.$forms.first());
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
    let position = $form.offset().top - this.scrollOffset; // leave room for header
    $('html, body').animate({ scrollTop: position }, 500);
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
      if (!$btn.hasClass('survey__skip-button')) {
        $btn.text(I18n.t('form.processing'))
      }
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
