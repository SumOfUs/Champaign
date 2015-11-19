const FormMethods = {

  handleFormErrors: function() {
    this.$('form').on('ajax:error', window.Champaign.showErrors);
  },

  selectizeCountry: function() {
    $('.action-bar__country-selector').selectize();
  },

  clearForm: function(){
    let $fields_holder = this.$('.form__group--prefilled');
    $fields_holder.removeClass('form__group--prefilled');
    $fields_holder.find('input').removeAttr('value');
    $('.action-bar__welcome-text').addClass('hidden-irrelevant');
  },

};

module.exports = FormMethods;
