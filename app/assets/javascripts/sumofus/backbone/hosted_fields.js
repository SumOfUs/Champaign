const HostedFields = Backbone.View.extend({

  el: '#hosted-fields',

  events: {
    // 'click .hosted-fields__step-number--past': 'triggerStepChange',
  },

  initialize: function() {
    this.setupBraintree();
  },

  setupBraintree: function() {
    braintree.setup(this.getClientToken(), "custom", {
      id: "hosted-fields",
      hostedFields: {
        number: {
          selector: ".hosted-fields__number"
        },
        cvv: {
          selector: ".hosted-fields__cvv"
        },
        expirationDate: {
          selector: ".hosted-fields__expiration"
        }
      }
    });
  },

  getClientToken: function() {
    return '{}';
  },

});

module.exports = HostedFields;
