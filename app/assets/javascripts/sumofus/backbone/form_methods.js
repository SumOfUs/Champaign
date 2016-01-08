let ErrorDisplay = require('show_errors');

const FormMethods = {

  handleFormErrors: function() {
    this.$('form').on('ajax:error', (e, d) => { ErrorDisplay.show(e, d); });
  },

  selectizeCountry: function() {
    $('.petition-bar__country-selector').selectize();
  },

  clearFormErrors: function() {
    ErrorDisplay.clearErrors(this.$('form'));
  },

  clearForm: function(){
    let $fields_holder = this.$('.form__group--prefilled');
    $fields_holder.removeClass('form__group--prefilled');
    $fields_holder.find('input').removeAttr('value');
    $('.petition-bar__welcome-text').addClass('hidden-irrelevant');
  },

  setCountry: function(countryCode){
    let selectize_el = this.$('select[name="country"]')[0];
    if (selectize_el) {
      selectize_el.selectize && selectize_el.selectize.addItem(countryCode);
    } else {
      $('select[name="country"]').val(countryCode);
    }
  },

  guessLocation: function(setCurrency=false) {
    $.ajax({
      url: '//freegeoip.net/json/',
      type: 'POST',
      dataType: 'jsonp',
      success: (location) => {
        this.setCountry(location.country_code);
        if(setCurrency) {
          this.setCurrencyFromCountry(location.country_code);
        }
      }
    });
  },

};

module.exports = FormMethods;
