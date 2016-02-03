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
    'ajax:success form.action': 'advanceToPayment',
    'submit form#hosted-fields': 'disableButton',
    'change select.fundraiser-bar__currency-selector': 'switchCurrency',
    'click .fundraiser-bar__engage-currency-switcher': 'showCurrencySwitcher',
    'click .fundraiser-bar__open-button': 'reveal',
    'click .fundraiser-bar__close-button': 'hide',
  },

  // options: object with any of the following keys
  //    followUpUrl: the url to redirect to after success
  //    currency: the three letter capitalized currency code to use
  //    amount: a preselected donation amount, if > 0 the first step will be skipped
  //    outstandingFields: the names of step 2 form fields that aren't satisfied by
  //      the values in the member hash.
  //    donationBands: an object with three letter currency codes as keys
  //    location: a hash of location values inferred from the user's request
  //    member: an object with fields that will prefill the form
  //    pageId: the ID of the plugin's page database record.
  //      and array of numbers, integers or floats, to display as donation amounts
  initialize (options = {}) {
    this.initializeCurrency(options.currency, options.donationBands)
    this.initializeSticky();
    this.initializeBraintree();
    this.handleFormErrors();
    this.changeStep(1);
    this.donationAmount = 0;
    this.followUpUrl = options.followUpUrl;
    this.initializeSkipping(options);
    this.pageId = options.pageId;
    if (!this.isMobile()) {
      this.selectizeCountry();
    }
    this.buttonText = I18n.t('form.submit');
    this.insertActionKitId('fundraiser', options.urlParams);
  },

  initializeSkipping (options){
    if (options.amount > 0) {
      this.setDonationAmount(options.amount);
    }
    this.hidingStepTwo = false;
    let amountKnown = (options.amount > 0); // non-numbers with > are always false
    let formComplete = this.formCanAutocomplete(options.outstandingFields, options.member);
    this.hideSteps(amountKnown, formComplete, options.member, options.location, options.outstandingFields);
  },

  hideSteps (amountKnown, formComplete, member, location, fieldsToSkipPrefill) {
    if (amountKnown && formComplete) {
      this.changeStep(3);
      this.hideSecondStep(member);
      this.completePrefill(member, location);
    } else if (formComplete) {
      this.hideSecondStep(member);
      this.completePrefill(member, location);
    } else if (amountKnown) {
      this.changeStep(2);
      this.partialPrefill(member, location, fieldsToSkipPrefill);
    } else {
      this.partialPrefill(member, location, fieldsToSkipPrefill);
    }
  },

  hideSecondStep (member) {
    this.$('.fundraiser-bar__steps').addClass('fundraiser-bar__steps--two-step');
    this.$('.fundraiser-bar__step-label[data-step="2"]').css('visibility', 'hidden');
    this.$('.fundraiser-bar__step-number[data-step="3"]').text(2);
    if (this.formFieldCount() > 0) { // don't offer to reveal fields if nothing to show
      this.showFormClearer('fundraiser', member);
    }
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
      this.buttonText = `<span class="fa fa-lock"></span><span>${I18n.t('fundraiser.donate', {amount: donationAmount})}</span>`;
      this.$('.fundraiser-bar__display-amount').text(donationAmount);
      this.$('.fundraiser-bar__submit-button').html(this.buttonText);
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
      if (this.followUpUrl) {
        this.redirectTo(this.followUpUrl);
      } else {
        // this should never happen, but just in case.
        alert(I18n.t('fundraiser.thank_you'));
      }
    }
  },

  transactionFailed () {
    return (data, status) => {
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
      _.each(messages, (error_message) => {
        $errors.append(`<div class="fundraiser-bar__error-detail">${error_message}</div>`);
      });
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
    this.$('.fundraiser-bar__errors').addClass('hidden-closed');
    this.$('.fundraiser-bar__submit-button').text(I18n.t('form.processing')).addClass('button--disabled');
  },

  enableButton () {
    this.$('.fundraiser-bar__submit-button').html(this.buttonText).removeClass('button--disabled');
  },

  redirectTo (url) {
    window.location.href = url;
  },

  hide: function() {
    this.$('.fundraiser-bar__mobile-view')
      .addClass('fundraiser-bar__mobile-view--closed')
      .removeClass('fundraiser-bar__mobile-view--open');
  },

  reveal: function() {
    this.$('.fundraiser-bar__mobile-view')
      .removeClass('fundraiser-bar__mobile-view--closed')
      .addClass('fundraiser-bar__mobile-view--open');
  },

}));

module.exports = FundraiserBar;
