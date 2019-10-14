import $ from 'jquery';
import I18n from 'champaign-i18n';
import Backbone from 'backbone';
import GlobalEvents from '../../../shared/global_events';
import DoubleOptIn from '../double_opt_in';
import Cookie from 'js-cookie';

import {
  changeCountry,
  changeVariant,
  changeConsent,
} from '../../../state/consent';

const PetitionAndScrollToConsent = Backbone.View.extend({
  el: '.petition-bar',

  globalEvents: {
    'form:validated': 'onValidateSuccess',
    'form:submitted': 'onSubmitSuccess',
  },

  // options: object with any of the following keys
  //    - followUpUrl: the url to redirect to after success.
  //    - onSubmitSuccess: when present this will be called
  //    after a successfull submission of the action form instead of
  //    the doing the redirect.
  initialize(options = {}) {
    this.user_id =
      window.champaign.personalization.member.id || Cookie.get('_facebook_uid');
    this.store = window.champaign.store;
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
    this.onSubmitSuccessCallback = options.onSubmitSuccess;

    GlobalEvents.bindEvents(this);
  },

  state() {
    return this.store.getState();
  },

  onValidateSuccess() {
    const { member, consent } = this.state();

    if (consent.isRequiredNew && !member) {
      this.petitionSidebar.fadeOut();
      this.petitionOverlayButton.fadeOut();
      this.displayAndScrollToConsentQuestion();
    } else {
      Backbone.trigger('form:submit_action_form');
    }
  },

  triggerRegistrationSuccessEvent(data) {
    const tracking = data.tracking;
    const member = window.champaign.personalization.member;
    if (tracking && !member.id) {
      if (typeof window.fbq === 'function') {
        if (tracking.user_id) {
          window.fbq('track', 'CompleteRegistration', tracking);
        }
      }
    }
  },

  onSubmitSuccess(e, data) {
    this.triggerRegistrationSuccessEvent(data);

    DoubleOptIn.handleActionSuccess(data);
    if (this.onSubmitSuccessCallback) {
      this.onSubmitSuccessCallback();
    } else {
      this.redirectToFollowUp();
    }
  },

  optInCallback() {
    window.champaign.store.dispatch(changeConsent(true));
    Backbone.trigger('form:submit_action_form');
  },

  optOutCallback() {
    window.champaign.store.dispatch(changeConsent(false));
    Backbone.trigger('form:submit_action_form');
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
});

export default PetitionAndScrollToConsent;
