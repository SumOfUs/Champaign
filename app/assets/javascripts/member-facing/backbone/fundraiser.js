const CurrencyMethods = require('./currency_methods');
const GlobalEvents = require('../../shared/global_events');

const Fundraiser = Backbone.View.extend(_.extend(CurrencyMethods, {
  el: '.fundraiser-bar',

  events: {
    'click .fundraiser-bar__step-name--past': 'triggerStepChange',
    'click .fundraiser-bar__step-number--past': 'triggerStepChange',
    'focus .fundraiser-bar__custom-field': 'primeCustom',
    'blur  .fundraiser-bar__custom-field': 'resetCustom',
    'click .fundraiser-bar__amount-button': 'advanceToDetails',
    'click .fundraiser-bar__first-continue': 'advanceToDetails',
    'click .action-form__clear-form': 'showSecondStep',
    'ajax:success form.action-form': 'advanceToNextStep',
    'submit form#hosted-fields': 'disableButton',
    'change select.fundraiser-bar__currency-selector': 'switchCurrency',
    'change input.fundraiser-bar__recurring': 'updateButton',
    'click .fundraiser-bar__engage-currency-switcher': 'showCurrencySwitcher',
    'click .hosted-fields__direct-debit': 'submitDirectDebit',
    'click .fundraiser-bar__submit-one-click': 'submitOneClick',
    'click .fundraiser-bar__toggle-payment-method': 'toggleOneClickVisibility',
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
    this.submissionCallback = options.submissionCallback;
    this.initializeSkipping(options);
    this.pageId = options.pageId;
    this.directDebitOpened = false;
    this.displayDirectDebit(options.showDirectDebit);
    this.initializeRecurring(options.recurringDefault);
    this.updateButton();
    this.paymentMethods = options.paymentMethods || [];
    this.setOneClickVisibility();
    GlobalEvents.bindEvents(this);
  },

  initializeRecurring(recurringDefault) {
    const $checkbox = this.$('input.fundraiser-bar__recurring');
    switch(recurringDefault) {
      case 'only_recurring':
        $checkbox.parents('.form__group').addClass('hidden-irrelevant');
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
    if (parsed > 0){
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

  toggleOneClickVisibility(event) {
    event.preventDefault();
    $('#one-click-form, #hosted-fields').toggleClass('hidden-irrelevant');
  },

  triggerStepChange(e) {
    const targetStep = this.$(e.target).parent().data('step');
    if (targetStep < this.currentStep) {
      this.changeStep(targetStep);
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

  submitDirectDebit() {
    let data = this.donationData();
    data.provider = 'GC';
    let url = `/api/go_cardless/pages/${this.pageId}/start_flow?${$.param(data)}`;
    $.publish('direct_debit:opened');
    this.directDebitOpened = true;
    window.open(url);
  },

  submitDonation (nonce) {
    let data = this.donationData();
    data.payment_method_nonce = nonce;
    $.post(`/api/payment/braintree/pages/${this.pageId}/transaction`, data).
      done(this.transactionSuccess.bind(this)).
      error(this.transactionFailed.bind(this));
    if(this.directDebitOpened){
      $.publish('direct_debit:donated_via_other');
    }
  },

  submitOneClick(event) {
    event.preventDefault();
    this.disableOneClickButton();
    $.post(`/api/payment/braintree/pages/${this.pageId}/one_click`, this.oneClickDonationData())
      .then(
        this.onOneClickSuccess.bind(this),
        this.onOneClickFailed.bind(this)
      );
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

  onOneClickSuccess() {
    const user = this.serializeUserForm();
    const url = `/api/member_authentication/new?page_id=${this.pageId}&email=${user.email}`;
    this.redirectTo(url);
  },

  onOneClickFailed() {
    this.enableOneClickButton();
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

  transactionSuccess(data, status) {
    let hasCallbackFunction = (typeof this.submissionCallback === 'function');
    if (hasCallbackFunction) {
      this.submissionCallback(data, status);
    }
    if (this.followUpUrl) {
      this.redirectTo(this.followUpUrl);
    }
    if (!this.followUpUrl && !hasCallbackFunction) {
      // only do this option if no redirect or callback supplied
      alert(I18n.t('fundraiser.thank_you'));
    }
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
    return _.mapValues(_.keyBy(list, 'name'), 'value');
  },

  readRecurring() {
    return !!this.$('input.fundraiser-bar__recurring').prop('checked');
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
}));

module.exports = Fundraiser;
