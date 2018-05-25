import $ from 'jquery';
import Backbone from 'backbone';
import GlobalEvents from '../../shared/global_events';
import {
  changeCountry,
  changeVariant,
  changeConsent,
} from '../../state/consent';

const PetitionAndScrollToConsent = Backbone.View.extend({
  el: '.petition-bar',

  globalEvents: {
    'form:submitted': 'formSubmittedCallback',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  initialize(options = {}) {
    this.followUpUrl = options.followUpUrl;
    this.petitionSidebar = $('.center-content__fixed-right');
    this.petitionOverlayButton = $('.petition-bar__mobile_ui__bottom_bar');
    this.consentQuestionStep = $(
      '.petition-and-scroll-to-consent__consent-question-wrapper'
    );
    this.optInButton = $('#opt-in-button');
    this.optOutButton = $('#opt-out-button');

    this.optInButton.on('click', this.optInCallback.bind(this));
    this.optOutButton.on('click', this.optOutCallback.bind(this));

    this.setupStore();
    GlobalEvents.bindEvents(this);
  },

  formSubmittedCallback(e, data) {
    var isValidateRequest = this.$('form.action-form')
      .attr('action')
      .match(/validate/);
    if (isValidateRequest) {
      this.petitionSidebar.fadeOut();
      this.petitionOverlayButton.fadeOut();
      this.displayAndScrollToConsentQuestion();
    } else {
      this.redirectToFollowUp();
    }
  },

  optInCallback() {
    window.champaign.store.dispatch(changeConsent(true));
    setTimeout(function() {
      window.champaign.myActionForm.updateActionUrl();
      this.$('form.action-form button[type=submit]').trigger('click');
    }, 300);
  },

  optOutCallback() {
    window.champaign.store.dispatch(changeConsent(false));
    setTimeout(function() {
      window.champaign.myActionForm.updateActionUrl();
      this.$('form.action-form button[type=submit]').trigger('click');
    }, 300);
  },

  displayAndScrollToConsentQuestion() {
    this.makeStepFullScreen(this.consentQuestionStep);
    this.consentQuestionStep.fadeIn();
    this.scrollTo(this.consentQuestionStep);
  },

  redirectToFollowUp(data) {
    if (data && data.follow_up_url) {
      this.redirectTo(data.follow_up_url);
    } else if (this.followUpUrl) {
      this.redirectTo(this.followUpUrl);
    } else {
      alert(I18n.t('petition.excited_confirmation'));
    }
  },

  makeStepFullScreen(stepElement) {
    var padding = parseInt(stepElement.css('padding-top'), 10);
    var margin = parseInt(stepElement.css('margin-bottom'), 10);
    var totalElementHeight = stepElement.height() + padding + margin;
    if (totalElementHeight < window.innerHeight) {
      stepElement.css(
        'margin-bottom',
        margin + (window.innerHeight - totalElementHeight)
      );
    }
  },

  scrollTo(element) {
    $('html, body').animate({ scrollTop: element.offset().top }, 800);
  },

  redirectTo(url) {
    window.location.href = url;
  },

  updateConsent(consented) {
    window.champaign.store.dispatch({
      type: '@@chmp:consent:change_consent',
      consented: consented,
    });
  },

  setupStore() {
    var store = champaign.store;
    var member = champaign.personalization.member;
    var countrySelect = this.$('select[name=country]');

    countrySelect.on('change', function() {
      store.dispatch(changeCountry(countrySelect.val()));
    });
    countrySelect.trigger('change');

    var consentField = this.$('input[name=consented]');
    store.subscribe(function() {
      consentField.val(store.getState().consent.consented);
    });
  },
});

export default PetitionAndScrollToConsent;
