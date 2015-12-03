const HostedFieldsMethods = {

  initializeBraintree: function() {
    this.getClientToken(this.setupFields());
  },

  setupFields: function() {
    return (clientToken) => {
      braintree.setup(clientToken, "custom", {
        id: "hosted-fields",
        onPaymentMethodReceived: this.paymentMethodReceived(),
        onError: this.handleErrors(),
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
            placeholder: "mm/yy",
          },
          styles: {
            input: {
              "font-size": "16px",
            },
          }
        }
      });
    }
  },

  handleErrors: function() {
    return (a, b) => {
      this.enableButton();
    }
  },

  getClientToken: function(callback) {
    $.get('/api/braintree/token', function(resp, success){
      callback(resp.token);
    });
  },

  paymentMethodReceived: function() {
    return (data) => {
      console.log("We have the nonce! Override this method to use it. Nonce:", data.nonce);
    }
  },
};

module.exports = HostedFieldsMethods;
