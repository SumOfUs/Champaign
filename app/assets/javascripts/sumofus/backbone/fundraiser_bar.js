const StickyMethods = require('sumofus/backbone/sticky_methods');
const FormMethods   = require('sumofus/backbone/form_methods');
const CurrencyMethods     = require('sumofus/backbone/currency_methods');
const HostedFieldsMethods = require('sumofus/backbone/hosted_fields');

const FundraiserBar = Backbone.View.extend(_.extend(
  StickyMethods, FormMethods, HostedFieldsMethods, CurrencyMethods, {

  el: '.fundraiser-bar',

  events: {
    'click .fundraiser-bar__step-name--past': 'triggerStepChange',
    'click .fundraiser-bar__step-number--past': 'triggerStepChange',
    'focus .fundraiser-bar__custom-field': 'primeCustom',
    'blur  .fundraiser-bar__custom-field': 'resetCustom',
    'click .fundraiser-bar__amount-button': 'advanceToDetails',
    'click .fundraiser-bar__first-continue': 'advanceToDetails',
    'click .fundraiser-bar__clear-form': 'showSecondStep',
    'click .action-bar__clear-form': 'clearForm',
    'ajax:success form.action': 'advanceToPayment',
    'submit form#hosted-fields': 'disableButton',
    'change select.fundraiser-bar__currency-selector': 'switchCurrency',
    'click .fundraiser-bar__engage-currency-switcher': 'showCurrencySwitcher',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    currency: the three letter capitalized currency code to use
  //    amount: a preselected donation amount, if > 0 the first step will be skipped
  //    outstandingFields: the number of step 2 form fields that need to to be filled by the user
  //    donationBands: an object with three letter currency codes as keys
  //      and array of numbers, integers or floats, to display as donation amounts
  initialize (options) {
    this.initializeCurrency(options.currency, options.donationBands)
    this.initializeSticky();
    this.initializeBraintree();
    this.changeStep(1);
    this.donationAmount = 0;
    this.handleFormErrors();
    this.followUpUrl = options.followUpUrl;
    this.initializeSkipping(options);
    this.pageId = options.pageId;
    if (!this.isMobile()) {
      this.selectizeCountry();
    }
  },

  initializeSkipping (options){
    if (options.amount > 0) {
      this.setDonationAmount(options.amount);
    }
    this.hidingStepTwo = false;
    // here we deliberately abuse the fact that non-numbers compared
    // with > always return false
    this.hideSteps((options.amount > 0), (options.outstandingFields == 0));
  },

  hideSteps (amountKnown, memberKnown) {
    if (amountKnown && memberKnown) {
      this.changeStep(3);
      this.hideSecondStep();
    } else if (memberKnown) {
      this.hideSecondStep();
    } else if (amountKnown) {
      this.changeStep(2);
    }
  },

  hideSecondStep () {
    this.$('.fundraiser-bar__steps').addClass('fundraiser-bar__steps--two-step');
    this.$('.fundraiser-bar__welcome-text').removeClass('hidden-irrelevant');
    this.$('.fundraiser-bar__step-label[data-step="2"]').css('visibility', 'hidden');
    this.$('.fundraiser-bar__step-number[data-step="3"]').text(2);
    this.hidingStepTwo = true;
  },

  showSecondStep () {
    this.$('.fundraiser-bar__steps').removeClass('fundraiser-bar__steps--two-step');
    this.$('.fundraiser-bar__welcome-text').addClass('hidden-irrelevant');
    this.$('.fundraiser-bar__step-label[data-step="2"]').css('visibility', 'visible');
    this.$('.fundraiser-bar__step-number[data-step="3"]').text(3);
    this.clearForm();
    this.hidingStepTwo = false;
    this.changeStep(2);
  },

  isMobile () {
    return $('.mobile-indicator').is(':visible');
  },

  primeCustom (e) {
    let $field = this.$(e.target);
    if ($field.val() == '') {
      $field[0].value = this.CURRENCY_SYMBOLS[this.currency];
    }
    this.$('.fundraiser-bar__first-continue').slideDown(200);
  },

  resetCustom (e) {
    let $field = this.$(e.target);
    let currencySymbols = /^[\$\£\€]*$/;
    if (currencySymbols.test($field.val())) {
      $field[0].value = '';
      this.$('.fundraiser-bar__first-continue').slideUp(200);
    };
  },

  advanceToPayment (e, data) {
    this.changeStep(this.currentStep+1);
  },

  advanceToDetails (e) {
    let amount = this.$(e.target).data('amount') || this.$('.fundraiser-bar__custom-field').val();
    if (typeof amount == 'string') {
      amount = amount.replace(/[\$\£\€]/g, '');
    }
    this.setDonationAmount(amount);
    if (this.donationAmount > 0) {
      this.hidingStepTwo ? this.changeStep(3) : this.changeStep(2);
    }
  },

  setDonationAmount (amount) {
    let parsed = parseFloat(amount);
    if (parsed > 0){
      this.donationAmount = parsed;
      let currencySymbol = this.CURRENCY_SYMBOLS[this.currency];
      let digits = (this.donationAmount === Math.floor(this.donationAmount)) ? 0 : 2;
      let donationAmount = `${currencySymbol}${this.donationAmount.toFixed(digits)}`;
      let buttonText = `<span class="fa fa-lock"></span><span>Donate ${donationAmount}</span>`
      this.$('.fundraiser-bar__display-amount').text(donationAmount);
      this.$('.fundraiser-bar__submit-button').html(buttonText);
    } else {
      this.changeStep(1);
    }
  },

  triggerStepChange (e) {
    const targetStep = this.$(e.target).parent().data('step');
    if (targetStep < this.currentStep) {
      this.changeStep(targetStep);
    }
  },

  changeStep (targetStep) {
    this.changeStepPanel(targetStep);
    this.changeStepNumber(targetStep);
    this.currentStep = targetStep;
  },

  changeStepPanel (targetStep) {
    this.$('.fundraiser-bar__step-panel').addClass('hidden-closed');
    this.$(`.fundraiser-bar__step-panel[data-step="${targetStep}"]`).removeClass('hidden-closed');
  },

  changeStepNumber (targetStep) {
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

  // for testing without waiting on braintree API
  fakeNonceSuccess (fakeData) {
    this.paymentMethodReceived()(fakeData);
  },

  paymentMethodReceived () {
    return (data) => {
      this.nonce = data.nonce;
      this.submitDonation();
    }
  },

  submitDonation () {
    $.post(`/api/braintree/pages/${this.pageId}/transaction`, {
      payment_method_nonce: this.nonce,
      amount:               this.donationAmount,
      user:                 this.serializeUserForm(),
      currency:             this.currency,
      recurring:            this.readRecurring()
    }).done(this.transactionSuccess()).
      error(this.transactionFailed());
  },

  transactionSuccess () {
    return (data, status) => {
      this.redirectTo(this.followUpUrl);
    }
  },

  transactionFailed () {
    return (data, status) => {
      this.enableButton();
      console.error('Transaction failed', data);
    }
  },

  serializeUserForm () {
    let list = this.$('form.action').serializeArray();
    let serialized = {}
    $.each(list, function(ii, field){
      serialized[field.name] = field.value;
    });
    return serialized;
  },

  readRecurring () {
    return this.$('input.fundraiser-bar__recurring').prop('checked') ? true : false
  },

  disableButton (e) {
    this.$('.fundraiser-bar__submit-button').text('Processing...').addClass('button--disabled');
  },

  enableButton () {
    this.$('.fundraiser-bar__submit-button').text('Submit').removeClass('button--disabled');
  },

  redirectTo (url) {
    window.location.href = url;
  }

}));

module.exports = FundraiserBar;
