const StickyMethods = require('sumofus/backbone/sticky_methods');

const FundraiserBar = Backbone.View.extend(_.extend(StickyMethods, {

  el: '.fundraiser-bar',

  events: {
    'click .fundraiser-bar__step-number': 'triggerStepChange',
    'focus .fundraiser-bar__custom-field': 'primeCustom',
    'blur .fundraiser-bar__custom-field': 'resetCustom',
  },

  initialize: function() {
    this.initializeSticky();
    this.changeStep(1);
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
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

  triggerStepChange: function(e) {
    this.changeStep(this.$(e.target).data('step'));
  },

  changeStep: function(targetStep) {
    // if (targetStep - this.currentStep > 1) {
    //   targetStep = this.currentStep + 1; // max advance of 1
    // }
    this.changeStepPanel(targetStep);
    this.changeStepNumber(targetStep);
    this.currentStep = targetStep;
  },

  changeStepPanel: function(targetStep) {
    this.$('.fundraiser-bar__step-panel').addClass('hidden-closed');
    this.$(`.fundraiser-bar__step-panel[data-step="${targetStep}"]`).removeClass('hidden-closed');
  },

  changeStepNumber: function(targetStep) {
    this.$('.fundraiser-bar__step-number').
      removeClass('fundraiser-bar__step-number--past').
      removeClass('fundraiser-bar__step-number--current').
      removeClass('fundraiser-bar__step-number--upcoming')
    this.$('.fundraiser-bar__step-number').each((ii, el) => {
      const step = this.$(el).data('step');
      if ( step < targetStep ) {
        $(el).addClass('fundraiser-bar__step-number--past');
      } else if ( step == targetStep) {
        $(el).addClass('fundraiser-bar__step-number--current');
      } else {
        $(el).addClass('fundraiser-bar__step-number--upcoming');
      }
    });
  },

}));

module.exports = FundraiserBar;
