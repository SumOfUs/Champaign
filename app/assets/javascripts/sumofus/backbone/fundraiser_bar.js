const StickyMethods = require('sumofus/backbone/sticky_methods');
const FormMethods   = require('sumofus/backbone/form_methods');
const HostedFieldsMethods = require('sumofus/backbone/hosted_fields');

const FundraiserBar = Backbone.View.extend(_.extend(
  StickyMethods, FormMethods, HostedFieldsMethods, {

  el: '.fundraiser-bar',

  events: {
    'click .fundraiser-bar__step-name--past': 'triggerStepChange',
    'click .fundraiser-bar__step-number--past': 'triggerStepChange',
    'focus .fundraiser-bar__custom-field': 'primeCustom',
    'blur  .fundraiser-bar__custom-field': 'resetCustom',
    'click .fundraiser-bar__amount-button': 'advanceToDetails',
    'click .fundraiser-bar__first-continue': 'advanceToDetails',
    'click .action-bar__clear-form': 'clearForm',
    'ajax:success form.action': 'handleValidationSuccess',
    'submit form#hosted-fields': 'disableButton',
  },

  initialize: function(follow_up_url) {
    this.initializeSticky();
    this.initializeBraintree();
    this.changeStep(1);
    this.donationAmount = 0;
    this.handleFormErrors();
    this.follow_up_url = follow_up_url;
    if (!this.isMobile()) {
      this.selectizeCountry();
    }
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },

  handleValidationSuccess: function(e, data) {
    this.changeStep(this.currentStep+1);
  },

  primeCustom: function(e) {
    let $field = this.$(e.target);
    if ($field.val() == '') {
      $field[0].value = '$';
    }
    this.$('.fundraiser-bar__first-continue').slideDown(200);
  },

  resetCustom: function(e) {
    let $field = this.$(e.target);
    if ($field.val() == '$' || $field.val() == '') {
      $field[0].value = '';
      this.$('.fundraiser-bar__first-continue').slideUp(200);
    }
  },

  advanceToDetails: function(e) {
    let amount = this.$(e.target).data('amount') || this.$('.fundraiser-bar__custom-field').val();
    if (typeof amount == 'string' && amount.indexOf('$') > -1) {
      amount = amount.replace('$', '');
    }
    this.setDonationAmount(amount);
    if (this.donationAmount > 0) {
      this.changeStep(2)
    }
  },

  setDonationAmount: function(amount) {
    let parsed = parseFloat(amount);
    if (parsed > 0){
      this.donationAmount = parsed;
      this.$('.fundraiser-bar__display-amount').text(`$${this.donationAmount}`);
    } else {
      this.changeStep(1);
    }
  },

  triggerStepChange: function(e) {
    const targetStep = this.$(e.target).parent().data('step');
    if (targetStep < this.currentStep) {
      this.changeStep(targetStep);
    }
  },

  changeStep: function(targetStep) {
    this.changeStepPanel(targetStep);
    this.changeStepNumber(targetStep);
    this.currentStep = targetStep;
  },

  changeStepPanel: function(targetStep) {
    this.$('.fundraiser-bar__step-panel').addClass('hidden-closed');
    this.$(`.fundraiser-bar__step-panel[data-step="${targetStep}"]`).removeClass('hidden-closed');
  },

  changeStepNumber: function(targetStep) {
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

  paymentMethodReceived: function() {
    return (data) => {
      this.nonce = data.nonce;
      this.submitDonation();
    }
  },

  submitDonation: function() {
    $.post('/api/braintree/transaction', {
      payment_method_nonce: this.nonce,
      amount: this.donationAmount,
      user: this.serializeUserForm(),
    }, this.handleTransaction());
  },

  handleTransaction: function() {
    return (data, status) => {
      this.enableButton();
      if (data.success) {
        console.log('transaction success!', data, status);
        window.location.href = this.follow_up_url
      } else {
        console.error('Transaction failed:', data);
      }
    }
  },

  serializeUserForm: function() {
    let list = this.$('form.action').serializeArray();
    let serialized = {}
    $.each(list, function(ii, field){
      serialized[field.name] = field.value;
    });
    return serialized;
  },

  disableButton: function(e) {
    this.$('.fundraiser-bar__submit-button').text('Processing...').addClass('button--disabled');
  },

  enableButton: function() {
    this.$('.fundraiser-bar__submit-button').text('Submit').removeClass('button--disabled');
  },

}));

module.exports = FundraiserBar;
