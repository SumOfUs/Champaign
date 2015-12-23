const HostedFieldsMethods = {

  initializeBraintree: function() {
    this.getClientToken(this.setupFields());
  },

  braintreeSettings: function() {
    return {
      id: "hosted-fields",
      onPaymentMethodReceived: this.paymentMethodReceived(),
      onError: this.handleErrors(),
      paypal: {
        container: 'hosted-fields__paypal',
        onCancelled: () => { this.$('.hosted-fields__credit-card-fields').slideDown(); },
        onSuccess: () => { this.$('.hosted-fields__credit-card-fields').slideUp(); },
        // when adding i18n, pass the locale param to paypal
      },
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
              this.showError(event.target.fieldKey, I18n.t('errors.probably_invalid'));
            }
            if (event.target.fieldKey == 'number') {
              if (event.isEmpty) {
                this.$('#hosted-fields__paypal').removeClass('paypal--grayed-out');
              } else {
                this.$('#hosted-fields__paypal').addClass('paypal--grayed-out');
              }
            }
            this.showCardType(event.card);
          }
        },
      },
    };
  },

  setupFields: function() {
    return (clientToken) => {
      braintree.setup(clientToken, "custom", this.braintreeSettings());
    }
  },

  handleErrors: function() {
    return (error) => {
      this.enableButton();
      if (error.details !== undefined && error.details.invalidFieldKeys !== undefined) {
        _.each(error.details.invalidFieldKeys, (key) => {
          this.showError(key, I18n.t('errors.is_invalid'));
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

  showCardType: function(card) {
    if (card == null || card.type == null ) {
      this.$('.hosted-fields__card-type').addClass('hidden-irrelevant');
    } else {
      let icons = {
        'diners-club': 'fa-cc-diners-club',
        'jcb': 'fa-cc-jcb',
        'american-express': 'fa-cc-amex',
        'discover': 'fa-cc-discover',
        'master-card': 'fa-cc-mastercard',
        'visa': 'fa-cc-visa',
      }
      let $cardType = this.$('.hosted-fields__card-type');
      $cardType.removeClass($cardType.data('card-class'));
      if (icons[card.type] !== undefined) {
        $cardType.addClass(icons[card.type]).data('card-class', icons[card.type]).removeClass('hidden-irrelevant');
      }
    }
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
};

module.exports = HostedFieldsMethods;
