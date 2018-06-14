import _ from 'lodash';

const CurrencyMethods = {
  DEFAULT_CURRENCY: 'USD',
  DEFAULT_DONATION_BANDS: {
    GBP: [1, 3, 10, 15, 35],
    USD: [2, 5, 10, 25, 50],
    EUR: [2, 5, 10, 25, 45],
    CHF: [1, 3, 10, 15, 35],
    AUD: [3, 10, 15, 35, 70],
    CAD: [3, 10, 15, 35, 70],
    NZD: [3, 10, 15, 35, 75],
  },
  CURRENCY_SYMBOLS: {
    USD: '$',
    EUR: '€',
    GBP: '£',
    CHF: 'Fr',
    CAD: '$',
    AUD: '$',
    NZD: '$',
  },

  showDonationBandForCurrency(currency) {
    const candidates = [
      [this.donationBands, currency],
      [this.DEFAULT_DONATION_BANDS, currency],
      [this.donationBands, 'USD'],
      [this.DEFAULT_DONATION_BANDS, 'USD'],
    ];
    for (let ii = 0; ii < candidates.length; ii++) {
      const denomination = candidates[ii][1];
      const band = candidates[ii][0][denomination];
      if (band !== undefined) {
        return this.showDonationBand(band, currency);
      }
    }
  },

  showDonationBand(amounts, currency) {
    const $buttonContainer = this.$('.fundraiser-bar__amount-buttons');
    $buttonContainer.html('');
    for (let ii = 0; ii < amounts.length; ii++) {
      const tag = `<div class="fundraiser-bar__amount-button" data-amount="${
        amounts[ii]
      }">${this.CURRENCY_SYMBOLS[currency]}${amounts[ii]}</div>`;
      $buttonContainer.append(tag);
    }
  },

  setCurrency(currency_with_case) {
    const currency = currency_with_case.toUpperCase();
    if (this.CURRENCY_SYMBOLS[currency] === undefined) {
      this.currency = this.DEFAULT_CURRENCY;
    } else {
      this.currency = currency;
    }
    this.$('.fundraiser-bar__current-currency').text(
      I18n.t('fundraiser.currency_in', { currency: this.currency })
    );
    this.$('select.fundraiser-bar__currency-selector')
      .find('option')
      .prop('selected', false);
    this.$('select.fundraiser-bar__currency-selector')
      .find(`option[value="${this.currency}"]`)
      .prop('selected', true);
    this.showDonationBandForCurrency(this.currency);
  },

  setupCurrencySelector() {
    const $select = this.$('select.fundraiser-bar__currency-selector');
    _.each(_.keys(this.CURRENCY_SYMBOLS), function(currency, ii) {
      const option = `<option value="${currency}">${currency}</option>`;
      $select.append(option);
    });
  },

  switchCurrency(e) {
    this.setCurrency(this.$('select.fundraiser-bar__currency-selector').val());
  },

  initializeCurrency(currency, donationBands) {
    this.setupCurrencySelector();
    this.donationBands = donationBands || this.DEFAULT_DONATION_BANDS;
    this.setCurrency(currency || this.DEFAULT_CURRENCY);
  },

  showCurrencySwitcher(e) {
    this.$('.fundraiser-bar__engage-currency-switcher').addClass(
      'hidden-irrelevant'
    );
    this.$('.fundraiser-bar__currency-selector').slideDown();
  },
};

export default CurrencyMethods;
