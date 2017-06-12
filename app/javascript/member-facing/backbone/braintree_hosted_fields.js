import $ from "jquery";
import _ from "lodash";
import Backbone from "backbone";

const BraintreeHostedFields = Backbone.View.extend({
  el: ".hosted-fields-view",
  TOKEN_WAIT_BEFORE_RETRY: 1500,
  TOKEN_RETRY_LIMIT: 5,
  SELECTOR_TO_HIDE_ON_PAYPAL_SUCCESS:
    ".hosted-fields__credit-card-fields, .hosted-fields__direct-debit-container",

  initialize() {
    this.getClientToken(this.setupFields.bind(this));
    this.tokenRetries = 0;
  },

  braintreeSettings() {
    return {
      id: "hosted-fields",
      onPaymentMethodReceived: this.paymentMethodReceived.bind(this),
      onError: this.handleErrors.bind(this),
      onReady: bt => {
        this.deviceData = bt.deviceData;
        this.hideSpinner();
      },
      dataCollector: {
        kount: { environment: "production" }
      },
      paypal: {
        container: "hosted-fields__paypal",
        onCancelled: () => {
          this.$(this.SELECTOR_TO_HIDE_ON_PAYPAL_SUCCESS).slideDown();
        },
        onSuccess: () => {
          this.$(this.SELECTOR_TO_HIDE_ON_PAYPAL_SUCCESS).slideUp();
        },
        locale: I18n.currentLocale()
      },
      hostedFields: {
        number: {
          selector: ".hosted-fields__number",
          placeholder: I18n.t("fundraiser.fields.number")
        },
        cvv: {
          selector: ".hosted-fields__cvv",
          placeholder: I18n.t("fundraiser.fields.cvv")
        },
        expirationDate: {
          selector: ".hosted-fields__expiration",
          placeholder: I18n.t("fundraiser.fields.expiration_format")
        },
        styles: {
          input: {
            "font-size": "16px"
          }
        },
        onFieldEvent: this.fieldUpdate.bind(this)
      }
    };
  },

  injectDeviceData(deviceData) {
    const $form = this.$("form");

    form.append(
      $("<input name='device_data' type='hidden' />").val(deviceData)
    );
  },

  fieldUpdate(event) {
    if (event.type === "fieldStateChange") {
      if (event.isPotentiallyValid) {
        this.clearError(event.target.fieldKey);
      } else {
        this.showError(
          event.target.fieldKey,
          I18n.t("errors.probably_invalid")
        );
      }
      if (event.target.fieldKey == "number") {
        if (event.isEmpty) {
          this.$(".hosted-fields__button-container").removeClass(
            "hosted-fields--grayed-out"
          );
        } else {
          this.$(".hosted-fields__button-container").addClass(
            "hosted-fields--grayed-out"
          );
        }
      }
      this.showCardType(event.card);
    }
  },

  setupFields(clientToken) {
    braintree.setup(clientToken, "custom", this.braintreeSettings());
  },

  hideSpinner() {
    this.$(".fundraiser-bar__fields-loading").addClass("hidden-closed");
    this.$("#hosted-fields").removeClass("hidden-closed");
    Backbone.trigger("sidebar:height_change");
  },

  handleErrors(error) {
    Backbone.trigger("fundraiser:server_error");
    if (
      error.details !== undefined &&
      error.details.invalidFieldKeys !== undefined
    ) {
      _.each(error.details.invalidFieldKeys, key => {
        this.showError(key, I18n.t("errors.is_invalid"));
      });
    }
  },

  showError(fieldName, msg) {
    fieldName = this.standardizeFieldName(fieldName);
    const $holder = $(`.hosted-fields__${fieldName}`).parent();
    $holder.find(".error-msg").remove();
    $holder.append(
      `<div class='error-msg'>${this.translateFieldName(
        fieldName
      )} ${msg}</div>`
    );
  },

  showCardType(card) {
    if (card == null || card.type == null) {
      this.$(".hosted-fields__card-type").addClass("hidden-irrelevant");
    } else {
      const icons = {
        "diners-club": "fa-cc-diners-club",
        jcb: "fa-cc-jcb",
        "american-express": "fa-cc-amex",
        discover: "fa-cc-discover",
        "master-card": "fa-cc-mastercard",
        visa: "fa-cc-visa"
      };
      const $cardType = this.$(".hosted-fields__card-type");
      $cardType.removeClass($cardType.data("card-class"));
      if (icons[card.type] !== undefined) {
        $cardType
          .addClass(icons[card.type])
          .data("card-class", icons[card.type])
          .removeClass("hidden-irrelevant");
      }
    }
  },

  clearError(fieldName) {
    fieldName = this.standardizeFieldName(fieldName);
    this.$(`.hosted-fields__${fieldName}`).parent().find(".error-msg").remove();
  },

  standardizeFieldName(fieldName) {
    return /expiration/.test(fieldName) ? "expiration" : fieldName;
  },

  translateFieldName(fieldName) {
    if (
      ["expiration", "cvv", "number", "postalCode"].indexOf(
        this.standardizeFieldName(fieldName)
      ) > -1
    ) {
      return I18n.t(`fundraiser.field_names.${fieldName}`);
    } else {
      return fieldName;
    }
  },

  getClientToken(callback) {
    $.get("/api/payment/braintree/token", function(resp, success) {
      callback(resp.token);
    }).fail(error => {
      // this code tries to fetch the token again and again
      // when fetching the token fails
      this.tokenRetries += 1;
      if (this.tokenRetries < this.TOKEN_RETRY_LIMIT) {
        window.setTimeout(() => {
          this.getClientToken(callback);
        }, this.TOKEN_WAIT_BEFORE_RETRY);
      }
    });
  },

  paymentMethodReceived(data) {
    Backbone.trigger("fundraiser:nonce_received", {
      nonce: data.nonce,
      deviceData: this.deviceData
    });
  }
});

export default BraintreeHostedFields;
