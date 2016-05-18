const BraintreeHostedFields = Backbone.View.extend({

  el: '.hosted-fields-view',

  initialize() {
    this.getClientToken(this.setupFields());
  },

  braintreeSettings() {
    return {
      id: "hosted-fields",
      onPaymentMethodReceived: this.paymentMethodReceived,
      onError: this.handleErrors(),
      onReady: this.hideSpinner(),
      paypal: {
        container: 'hosted-fields__paypal',
        onCancelled: () => { this.$('.hosted-fields__credit-card-fields').slideDown(); },
        onSuccess: () => { this.$('.hosted-fields__credit-card-fields').slideUp(); },
        locale: I18n.currentLocale(),
      },
      hostedFields: {
        number: {
          selector: ".hosted-fields__number",
          placeholder: I18n.t('fundraiser.fields.number'),
        },
        cvv: {
          selector: ".hosted-fields__cvv",
          placeholder: I18n.t('fundraiser.fields.cvv'),
        },
        expirationDate: {
          selector: ".hosted-fields__expiration",
          placeholder: I18n.t('fundraiser.fields.expiration_format'),
        },
        styles: {
          input: {
            "font-size": "16px",
          },
        },
        onFieldEvent: this.fieldUpdate(),
      },
    };
  },

  fieldUpdate() {
    return (event) => {
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
    }
  },

  setupFields() {
    return (clientToken) => {
      braintree.setup(clientToken, "custom", this.braintreeSettings());
    }
  },

  hideSpinner() {
    return (clientToken) => {
      this.$('.fundraiser-bar__fields-loading').addClass('hidden-closed');
      this.$('#hosted-fields').removeClass('hidden-closed');
      $.publish('sidebar:height_change');
    }
  },

  handleErrors() {
    return (error) => {
      $.publish('fundraiser:server_error');
      if (error.details !== undefined && error.details.invalidFieldKeys !== undefined) {
        _.each(error.details.invalidFieldKeys, (key) => {
          this.showError(this.translateKey(key), I18n.t('errors.is_invalid'));
        });
      }
    }
  },

  showError(fieldName, msg) {
    fieldName = this.standardizeFieldName(fieldName);
    let $holder = $(`.hosted-fields__${fieldName}`).parent();
    $holder.find('.error-msg').remove();
    $holder.append(`<div class='error-msg'>${this.translateFieldName(fieldName)} ${msg}</div>`);
  },

  showCardType(card) {
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

  clearError(fieldName) {
    fieldName = this.standardizeFieldName(fieldName);
    this.$(`.hosted-fields__${fieldName}`).parent().find('.error-msg').remove();
  },

  standardizeFieldName(fieldName) {
    return /expiration/.test(fieldName) ? 'expiration' : fieldName;
  },

  translateFieldName(fieldName) {
    if (['expiration', 'cvv', 'number', 'postalCode'].indexOf(this.standardizeFieldName(fieldName)) > -1) {
      return I18n.t(`fundraiser.field_names.${fieldName}`)
    } else {
      return fieldName;
    }
  },

  getClientToken(callback) {
    $.get('/api/payment/braintree/token', function(resp, success){
      callback(resp.token);
    });
  },

  paymentMethodReceived (data) {
    $.publish('fundraiser:nonce_received', data.nonce);
  },
});

module.exports = BraintreeHostedFields;
