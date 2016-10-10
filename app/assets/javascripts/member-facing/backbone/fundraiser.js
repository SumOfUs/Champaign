import mapValues from 'lodash/mapValues';
import keyBy from 'lodash/keyBy';
import Cookies from 'js-cookie';

const CurrencyMethods = require('./currency_methods');
const GlobalEvents = require('../../shared/global_events');
const PaymentMethodsView = require('./payment-methods/payment-methods.view');

const Fundraiser = Backbone.View.extend(_.extend(CurrencyMethods, {
  el: '.fundraiser-bar',

  events: {
    'click .fundraiser-bar__step-name--past': 'triggerStepChange',
    'click .fundraiser-bar__step-number--past': 'triggerStepChange',
    'focus .fundraiser-bar__custom-field': 'primeCustom',
    'blur  .fundraiser-bar__custom-field': 'resetCustom',
    'click .fundraiser-bar__amount-button': 'advanceToDetails',
    'click .fundraiser-bar__first-continue': 'advanceToDetails',
    'click .action-form__clear-form': 'resetUser',
    'ajax:success form.action-form': 'advanceToNextStep',
    'submit form#hosted-fields': 'disableButton',
    'change select.fundraiser-bar__currency-selector': 'switchCurrency',
    'change input.fundraiser-bar__recurring': 'updateButton',
    'change input.fundraiser-bar__recurring-one-click': 'updateButton',
    'click .fundraiser-bar__engage-currency-switcher': 'showCurrencySwitcher',
    'click .hosted-fields__direct-debit': 'submitDirectDebit',
    'click .fundraiser-bar__submit-one-click': 'submitOneClick',
    'click .fundraiser-bar__toggle-payment-method': 'hideOneClickForm',
  },

  globalEvents: {
    'fundraiser:server_error': 'enableButton',
    'fundraiser:nonce_received': 'submitDonation',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    submissionCallback: a function to call after success, receives the
  //      arguments received by the ajax call posting the donation
  //    currency: the three letter capitalized currency code to use
  //    amount: a preselected donation amount, if > 0 the first step will be skipped
  //    showDirectDebit: boolean, whether to show the direct debit option
  //    donationBands: an object with three letter currency codes as keys
  //    recurringDefault: either 'donation', 'recurring', or 'only_recurring'
  //    pageId: the ID of the plugin's page database record.
  //      and array of numbers, integers or floats, to display as donation amounts
  initialize(options = {}) {
    this.initializeCurrency(options.currency, options.donationBands)
    this.changeStep(1);
    this.donationAmount = 0;
    this.followUpUrl = options.followUpUrl;
    if (typeof options.submissionCallback === 'function') {
      this.submissionCallback = options.submissionCallback;
    }

    this.initializeSkipping(options);
    this.pageId = options.pageId;
    this.directDebitOpened = false;
    this.displayDirectDebit(options.showDirectDebit);

    this.paymentMethods = new Backbone.Collection(options.paymentMethods || []);
    this.paymentMethodsView = new PaymentMethodsView({ collection: this.paymentMethods });

    this.setOneClickVisibility();
    this.initializeRecurring(options.recurringDefault);
    this.updateButton();

    GlobalEvents.bindEvents(this);

  },

  initializeRecurring(recurringDefault) {
    const $checkbox = this.$('input.fundraiser-bar__recurring, input.fundraiser-bar__recurring-one-click');

    switch(recurringDefault) {
      case 'only_recurring':
        $checkbox.parents('label').addClass('hidden-irrelevant');
        // deliberate fall-through to next case (no break)
      case 'recurring':
        $checkbox.prop('checked', true);
        break;
      default:
        $checkbox.prop('checked', false);
    }
  },

  initializeSkipping(options){
    if (options.amount > 0) {
      this.setDonationAmount(options.amount);
    }
    this.hidingStepTwo = false;
    let amountKnown = (options.amount > 0); // non-numbers with > are always false
    let formComplete = this.$('.action-form').data('prefilled');
    this.hideSteps(amountKnown, formComplete);
  },

  hideSteps(amountKnown, formComplete) {
    if (amountKnown && formComplete) {
      this.changeStep(3);
      this.hideSecondStep();
    } else if (formComplete) {
      this.hideSecondStep();
    } else if (amountKnown) {
      this.changeStep(2);
    }
  },

  hideSecondStep() {
    this.$('.fundraiser-bar__steps').addClass('fundraiser-bar__steps--two-step');
    this.$('.fundraiser-bar__step-label[data-step="2"]').css('visibility', 'hidden');
    this.$('.fundraiser-bar__step-number[data-step="3"]').text(2);
    this.hidingStepTwo = true;
  },

  showSecondStep() {
    this.$('.fundraiser-bar__steps').removeClass('fundraiser-bar__steps--two-step');
    this.$('.fundraiser-bar__welcome-text').addClass('hidden-irrelevant');
    this.$('.fundraiser-bar__step-label[data-step="2"]').css('visibility', 'visible');
    this.$('.fundraiser-bar__step-number[data-step="3"]').text(3);
    Backbone.trigger('form:clear');
    this.hidingStepTwo = false;
    this.changeStep(2);
  },

  resetUser() {
    this.paymentMethods.reset([]);
    this.showSecondStep();
    this.hideOneClickForm();
    Cookies.remove('authentication_id');
    Cookies.remove('payment_methods');
  },

  primeCustom(e) {
    let $field = this.$(e.target);
    if ($field.val() == '') {
      $field[0].value = this.CURRENCY_SYMBOLS[this.currency];
    }
    this.$('.fundraiser-bar__first-continue').slideDown(200);
  },

  resetCustom(e) {
    let $field = this.$(e.target);
    let currencySymbols = /^[\$\u20ac\u00a3]*$/; // \u00a3 is £, \u20ac is €
    if (currencySymbols.test($field.val())) {
      $field[0].value = '';
      this.$('.fundraiser-bar__first-continue').slideUp(200);
    };
  },

  advanceToNextStep (e, data) {
    this.changeStep(this.currentStep+1);
  },

  advanceToDetails(e) {
    let amount = this.$(e.target).data('amount') || this.$('.fundraiser-bar__custom-field').val();
    if (typeof amount == 'string') {
      // \u00a3 is £, \u20ac is €
      amount = amount.replace(/[\$\u20ac\u00a3]/g, '');
    }
    this.setDonationAmount(amount);
    if (this.donationAmount > 0) {
      this.hidingStepTwo ? this.changeStep(3) : this.changeStep(2);
    }
  },

  setDonationAmount(amount) {
    let parsed = parseFloat(amount);
    if (parsed > 0) {
      this.donationAmount = parsed;
      this.updateButton();
    } else {
      this.changeStep(1);
    }
  },

  updateButton() {
    if (this.donationAmount > 0) {
      let currencySymbol = this.CURRENCY_SYMBOLS[this.currency];
      let digits = (this.donationAmount === Math.floor(this.donationAmount)) ? 0 : 2;
      let donationAmount = `${currencySymbol}${this.donationAmount.toFixed(digits)}`;
      let monthly = this.readRecurring() ? `<span> / ${I18n.t('fundraiser.month')}</span>` : '';
      this.buttonText = `<span class="fa fa-lock"></span>
                         <span>${I18n.t('fundraiser.donate', {amount: donationAmount})}</span>
                         ${monthly}`;
      this.$('.fundraiser-bar__display-amount').text(donationAmount);
      this.$('.fundraiser-bar__submit-button').html(this.buttonText);
      this.$('.fundraiser-bar__submit-one-click').html(this.buttonText);
    }
  },

  setOneClickVisibility() {
    if (this.paymentMethods.length) {
      // hide braintree widgethide
      $('#hosted-fields').addClass('hidden-irrelevant');
      $('.fundraiser-bar__fields-loading').addClass('hidden-closed');
    } else {
      $('#one-click-form').addClass('hidden-irrelevant');
    }
  },

  hideOneClickForm(event) {
    if (event) {
      event.preventDefault();
    }
    $('#one-click-form').addClass('hidden-irrelevant');
    $('#hosted-fields').removeClass('hidden-irrelevant');
  },

  oneClickShowing() {
    return !$('#one-click-form').hasClass('hidden-irrelevant');
  },

  triggerStepChange(e) {
    const targetStep = this.$(e.target).parent().data('step');
    if (targetStep < this.currentStep) {
      this.changeStep(targetStep);
      Backbone.trigger('form:step_change', targetStep);
    }
  },

  changeStep(targetStep) {
    this.changeStepPanel(targetStep);
    this.changeStepNumber(targetStep);
    this.currentStep = targetStep;
    Backbone.trigger('sidebar:height_change');
  },

  changeStepPanel(targetStep) {
    this.$('.fundraiser-bar__step-panel').addClass('hidden-closed');
    this.$(`.fundraiser-bar__step-panel[data-step="${targetStep}"]`).removeClass('hidden-closed');
  },

  changeStepNumber(targetStep) {
    $.each(['number', 'name'], (ii, part) => {
      this.$(`.fundraiser-bar__step-${part}`).
        removeClass(`fundraiser-bar__step-${part}--past`).
        removeClass(`fundraiser-bar__step-${part}--current`).
        removeClass(`fundraiser-bar__step-${part}--upcoming`);
      this.$(`.fundraiser-bar__step-${part}`).each((ii, el) => {
        const step = this.$(el).parent().data('step');
        if ( step < targetStep ) {
          $(el).addClass(`fundraiser-bar__step-${part}--past`);
        } else if ( step == targetStep) {
          $(el).addClass(`fundraiser-bar__step-${part}--current`);
        } else {
          $(el).addClass(`fundraiser-bar__step-${part}--upcoming`);
        }
      });
    });
  },

  donationData() {
    return {
      amount:         this.donationAmount,
      user:           this.serializeUserForm(),
      currency:       this.currency,
      recurring:      this.readRecurring(),
      store_in_vault: this.readStoreInVault(),
    };
  },

  oneClickDonationData() {
    const paymentMethodId = $('#one-click-form input[name=payment_method_id]:checked').val();
    const data = {
      payment: {
        currency: this.currency,
        amount: this.donationAmount,
        recurring: this.readRecurringOneClick(),
        payment_method_id: paymentMethodId,
      },
      user: this.serializeUserForm(),
    };

    return data;
  },

  submitDirectDebit() {
    let data = this.donationData();
    data.provider = 'GC';
    let url = `/api/go_cardless/pages/${this.pageId}/start_flow?${$.param(data)}`;
    $.publish('direct_debit:opened');
    this.directDebitOpened = true;
    window.open(url);
  },

  submitDonation(nonce) {
    let data = this.donationData();
    data.payment_method_nonce = nonce;
    $.post(`/api/payment/braintree/pages/${this.pageId}/transaction`, data)
      .then(this.onSubmission.bind(this))
      .then(this.transactionSuccess.bind(this), this.transactionFailed.bind(this));

    if (this.directDebitOpened) {
      $.publish('direct_debit:donated_via_other');
    }
  },

  onSubmission(data, status) {
    if (this.submissionCallback) {
      this.submissionCallback(data, status);
    }
  },

  submitOneClick(event) {
    event.preventDefault();
    const url = `/api/payment/braintree/pages/${this.pageId}/one_click`;
    this.disableOneClickButton();
    $.post(url, this.oneClickDonationData())
      .then(this.onSubmission.bind(this))
      .then(this.onOneClickSuccess.bind(this), this.onOneClickFailed.bind(this));
  },

  onOneClickSuccess(e, data) {
    if ( this.memberShouldRegister() ) {
      this.followRedirect(this.registrationPath(window.champaign.personalization.member.email));
    } else {
      this.followRedirect((data && data.follow_up_url) || this.followUpUrl);
    }
  },

  transactionSuccess(e, data) {
    const user = this.serializeUserForm();
    let url = (data && data.follow_up_url) || this.followUpUrl;

    if ( this.memberShouldRegister() ) {
      url = this.registrationPath(user.email);
    }

    this.followRedirect(url);
  },

  registrationPath(email) {
    return `/member_authentication/new?page_id=${this.pageId}&email=${encodeURIComponent(email)}`;
  },

  onOneClickFailed() {
    this.enableOneClickButton();
  },

  transactionFailed(data, status) {
    this.enableButton();
    let $errors = this.$('.fundraiser-bar__errors');
    $errors.removeClass('hidden-closed');
    $errors.find('.fundraiser-bar__error-detail').remove();
    if (data.status == 422 && data.responseJSON && data.responseJSON.errors) {
      var messages = data.responseJSON.errors.map(function(error){
        if (error.declined) {
          return I18n.t('fundraiser.card_declined')
        } else {
          return error.message;
        }
      });
    } else {
      var messages = [I18n.t('fundraiser.unknown_error')];
    }
    this.showErrors(messages);
    Backbone.trigger('sidebar:height_change');
  },

  enableOneClickButton() {
    this.$('.fundraiser-bar__submit-one-click')
      .html(this.buttonText)
      .removeClass('button--disabled')
      .prop('disabled', false);
  },

  disableOneClickButton() {
    this.$('.fundraiser-bar__submit-one-click')
      .text(I18n.t('form.processing'))
      .addClass('button--disabled')
      .prop('disabled', true);
  },

  showErrors(messages) {
    let $errors = this.$('.fundraiser-bar__errors');
    $errors.removeClass('hidden-closed');
    $errors.find('.fundraiser-bar__error-detail').remove();
    _.each(messages, (error_message) => {
      $errors.append(`<div class="fundraiser-bar__error-detail">${error_message}</div>`);
    });
  },

  serializeUserForm() {
    const list = this.$('form.action-form').serializeArray();
    return mapValues(keyBy(list, 'name'), 'value');
  },

  readRecurring() {
    if(this.oneClickShowing()) {
      return !!this.$('input.fundraiser-bar__recurring-one-click').prop('checked');
    } else {
      return !!this.$('input.fundraiser-bar__recurring').prop('checked');
    }
  },

  readRecurringOneClick() {
    return !!this.$('input.fundraiser-bar__recurring-one-click').prop('checked');
  },

  readStoreInVault() {
    return this.$('input.fundraiser-bar__store-in-vault').prop('checked');
  },

  disableButton() {
    this.$('.fundraiser-bar__errors').addClass('hidden-closed');
    this.$('.fundraiser-bar__submit-button')
      .text(I18n.t('form.processing'))
      .addClass('button--disabled')
      .prop('disabled', true);
  },

  enableButton() {
    this.$('.fundraiser-bar__submit-button')
      .html(this.buttonText)
      .removeClass('button--disabled')
      .prop('disabled', false);
  },

  followRedirect(url) {
    // If we have no redirect URL or submission callback,
    // we display a thank you message
    if (!url && !this.submissionCallback) {
      alert(I18n.t('fundraiser.thank_you'));
      return;
    }

    this.redirectTo(url);
  },

  redirectTo(url) {
    window.location.href = url;
  },

  displayDirectDebit(show) {
    if (show === true) {
      $('.hosted-fields__direct-debit-container').removeClass('hidden-irrelevant');
      this.handleInterTabFollowUp();
    } else {
      $('.hosted-fields__direct-debit-container').addClass('hidden-irrelevant');
    }
  },

  handleInterTabFollowUp() {
    $(window).on('message', (e) => {
      if (typeof e.originalEvent.data === 'object') {
        if (e.originalEvent.data.event === 'follow_up:loaded') {
          this.redirectTo(this.followUpUrl);
          e.originalEvent.source.close();
          $.publish('direct_debit:donated');
        } else if (e.originalEvent.data.event === 'donation:error') {
          const messages = e.originalEvent.data.errors.map(({ message }) => message);
          this.showErrors(messages);
          e.originalEvent.source.close();
        }
      }
    });
  },

  memberRegistered() {
    return window.champaign.personalization.member.registered;
  },

  memberShouldRegister() {
    return !this.memberRegistered() && this.readStoreInVault();
  },
}));

module.exports = Fundraiser;
