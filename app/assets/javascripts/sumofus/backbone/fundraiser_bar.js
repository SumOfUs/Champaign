const StickyMethods = require('sumofus/backbone/sticky_methods');

const FundraiserBar = Backbone.View.extend(_.extend(StickyMethods, {

  el: '.fundraiser-bar',

  events: {
    'click .fundraiser-bar__step-number': 'triggerStepChange'
  },

  initialize: function() {
    this.initializeSticky();
    this.changeStep(1);
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },

  triggerStepChange: function(e) {
    this.changeStep(this.$(e.target).data('step'));
  },

  changeStep: function(targetStep) {
    // if (targetStep - this.currentStep > 1) {
    //   targetStep = this.currentStep + 1; // max advance of 1
    // }
    this.$('.fundraiser-bar__step-number').
      removeClass('fundraiser-bar__step-number--past').
      removeClass('fundraiser-bar__step-number--current').
      removeClass('fundraiser-bar__step-number--upcoming')

    this.currentStep = targetStep;
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
  }

}));

module.exports = FundraiserBar;
