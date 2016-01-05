const FormMethods = {

  handleFormErrors: function() {
    this.$('form').on('ajax:error', window.Champaign.showErrors);
  },

  selectizeCountry: function() {
    $('.petition-bar__country-selector').selectize();
  },

  clearForm: function(){
    let $fields_holder = this.$('.form__group--prefilled');
    $fields_holder.removeClass('form__group--prefilled');
    $fields_holder.find('input').removeAttr('value');
    $('.petition-bar__welcome-text').addClass('hidden-irrelevant');
  },

  setCountry: function(countryCode){
    let selectize = this.$('select[name="country"]')[0].selectize
    if (selectize) {
      selectize.addItem(countryCode);
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
