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
          },
          onFieldEvent: (event) => {
            if (event.type === "fieldStateChange"){
              if (event.isPotentiallyValid) {
                this.clearError(event.target.fieldKey);
              } else {
                this.showError(event.target.fieldKey, "doesn't look right");
              }
            }
          },
        },
      });
    }
  },

  handleErrors: function() {
    return (error) => {
      this.enableButton();
      if (error.details !== undefined && error.details.invalidFieldKeys !== undefined) {
        _.each(error.details.invalidFieldKeys, (key) => {
          this.showError(key, 'is invalid');
        });
      }
    }
  },

  showError: function(field_name, msg) {
    field_name = this.standardizeFieldName(field_name);
    let $holder = $(`.hosted-fields__${field_name}`).parent();
    $holder.find('.error-msg').remove();
    $holder.append(`<div class='error-msg'>${field_name} ${msg}</div>`);
  },

  clearError: function(field_name) {
    field_name = this.standardizeFieldName(field_name);
    this.$(`.hosted-fields__${field_name}`).parent().find('.error-msg').remove();
  },

  standardizeFieldName: function(field_name) {
    return /expiration/.test(field_name) ? 'expiration' : field_name;
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
