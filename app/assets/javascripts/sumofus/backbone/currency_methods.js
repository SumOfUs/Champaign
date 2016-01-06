const CurrencyMethods = {
  DEFAULT_CURRENCY: 'USD',
  DEFAULT_DONATION_BANDS: {
    'GBP': [1, 3, 10, 15, 35],
    'USD': [2, 5, 10, 25, 50],
    'EUR': [2, 5, 10, 25, 45],
    'AUD': [3, 10, 15, 35, 70],
    'CAD': [3, 10, 15, 35, 70],
    'NZD': [3, 10, 15, 35, 75]
  },
  CURRENCY_SYMBOLS: {
    'USD': '$',
    'EUR': '€',
    'GBP': '£',
    'CAD': '$',
    'AUD': '$',
    'NZD': '$',
  },
  COUNTRY_TO_CURRENCY_MAP: {
    'US': 'USD',
    'GB': 'GBP',
    'NZ': 'NZD',
    'AU': 'AUD',
    'CA': 'CAD'
  },
  EURO_COUNTRY_CODES: ['AL', 'AD', 'AT', 'BY', 'BE', 'BA', 'BG', 'HR', 'CY',
     'CZ', 'DK', 'EE', 'FO', 'FI', 'FR', 'DE', 'GI', 'GR', 'HU', 'IS', 'IE',
     'IT', 'LV', 'LI', 'LT', 'LU', 'MK', 'MT', 'MD', 'MC', 'NL', 'NO', 'PL',
     'PT', 'RO', 'RU', 'SM', 'RS', 'SK', 'SI', 'ES', 'SE', 'CH', 'UA', 'VA',
     'RS', 'IM', 'RS', 'ME'],

  showDonationBandForCurrency: function(currency) {
    let candidates = [[this.donationBands,          currency],
                  [this.DEFAULT_DONATION_BANDS, currency],
                  [this.donationBands,          'USD'],
                  [this.DEFAULT_DONATION_BANDS, 'USD']];
    for (let ii = 0; ii < candidates.length; ii++) {
      let denomination = candidates[ii][1];
      let band = candidates[ii][0][denomination];
      if (band !== undefined) {
        return this.showDonationBand(band, currency);
      }
    };
  },

  showDonationBand: function(amounts, currency) {
    let $buttonContainer = this.$('.fundraiser-bar__amount-buttons');
    $buttonContainer.html('');
    for (let ii = 0; ii < amounts.length; ii++) {
      let tag = `<div class="fundraiser-bar__amount-button" data-amount="${amounts[ii]}">${this.CURRENCY_SYMBOLS[currency]}${amounts[ii]}</div>`
      $buttonContainer.append(tag);
    };
  },

  setCurrency: function(currency) {
    if( this.CURRENCY_SYMBOLS[currency] === undefined) {
      this.currency = this.DEFAULT_CURRENCY;
    } else {
      this.currency = currency;
    }
    this.$('.fundraiser-bar__current-currency').text(this.currency);
    this.$('select.fundraiser-bar__currency-selector').find('option').prop('selected', false);
    this.$('select.fundraiser-bar__currency-selector').find(`option[value="${this.currency}"]`).prop('selected', true);
    this.showDonationBandForCurrency(this.currency);
  },

  setCurrencyFromCountry: function(countryCode) {
    if (_.indexOf(EURO_COUNTRY_CODES, countryCode) > -1) {
      return this.setCurrency('EUR');
    } else if (COUNTRY_TO_CURRENCY_MAP.hasOwnProperty(countryCode)) {
      return this.setCurrency(COUNTRY_TO_CURRENCY_MAP[countryCode]);
    } else {
      // we don't support this country's currency
    }
  },

  setupCurrencySelector: function() {
    let $select = this.$('select.fundraiser-bar__currency-selector');
    _.each(_.keys(this.CURRENCY_SYMBOLS), function(currency, ii){
      let option = `<option value="${currency}">${currency}</option>`
      $select.append(option);
    });
  },

  switchCurrency: function(e) {
    this.setCurrency(this.$('select.fundraiser-bar__currency-selector').val());
  },

  initializeCurrency: function(currency, donationBands) {
    this.setupCurrencySelector();
    this.donationBands = donationBands || this.DEFAULT_DONATION_BANDS;
    this.setCurrency(currency || this.DEFAULT_CURRENCY);
  },

  showCurrencySwitcher: function(e) {
    this.$('.fundraiser-bar__engage-currency-switcher').addClass('hidden-irrelevant');
    this.$('.fundraiser-bar__currency-selector').slideDown();
  },
}

module.exports = CurrencyMethods;