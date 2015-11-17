const HostedFields = Backbone.View.extend({

  el: '#hosted-fields',

  events: {
    // 'click .hosted-fields__step-number--past': 'triggerStepChange',
  },

  initialize: function() {
    this.setupBraintree();
  },

  setupBraintree: function() {
    this.getClientToken(this.setupFields);
  },

  setupFields: function(clientToken) {
    braintree.setup(clientToken, "custom", {
      id: "hosted-fields",
      hostedFields: {
        number: {
          selector: ".hosted-fields__number",
          placeholder: "Card number",
        },
        cvv: {
          selector: ".hosted-fields__cvv",
          placeholder: "CVV",
        },
        expirationDate: {
          selector: ".hosted-fields__expiration",
          placeholder: "Expiration",
        },
        styles: {
          input: {
            "font-size": "16px",
          },
        }
      }
    });
  },

  getClientToken: function(callback) {
    $.get('/api/braintree/token', function(resp, success){
      callback(resp.token);
    });
  },

});

module.exports = HostedFields;
