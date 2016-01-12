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

  prefillForm: function(member, outstandingFields){
    if(typeof outstandingFields !== typeof []) { return; }
    if(typeof member !== typeof {}) { return; }
    this.$('.petition-bar__field-container').each((ii, container) => {
      let $container = $(container);
      let $field = $container.find('input, select');
      let name = $field.attr('name');
      if (outstandingFields.indexOf(name) > -1) {
        return; // if its marked outstanding, the value we have wouldn't pass validation
      } else if(outstandingFields.length === 0) {
        $container.addClass('form__group--prefilled');
      }
      if (member.hasOwnProperty(name)) {
        $field.val(member[name]);
      }
    });
  },

  formFieldCount: function() {
    return this.$('.petition-bar__field-container').length;
  },

  showFormClearer: function(member) {
    this.$().member.welcome_name
  }
};

module.exports = FormMethods;
