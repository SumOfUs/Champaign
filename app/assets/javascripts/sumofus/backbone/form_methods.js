let ErrorDisplay = require('show_errors');

const FormMethods = {

  handleFormErrors() {
    this.$('form').on('ajax:error', (e, d) => { ErrorDisplay.show(e, d); });
  },

  selectizeCountry() {
    $('.petition-bar__country-selector').selectize();
  },

  clearFormErrors() {
    ErrorDisplay.clearErrors(this.$('form'));
  },

  formCanAutocomplete(outstandingFields, member) {
    return (_.isArray(outstandingFields) &&
            outstandingFields.length === 0 &&
            (this.formFieldCount() === 0 || _.isObject(member)));
  },

  clearForm(){
    let $fields_holder = this.$('.form__group--prefilled');
    $fields_holder.removeClass('form__group--prefilled');
    $fields_holder.find('input, select').val('');
    $fields_holder.find('select').each((ii, el)=>{ el.selectedIndex = -1; });
    $fields_holder.find('.selectized').each((ii, el)=>{ el.selectize.clear(); });
    $fields_holder.parents('form').trigger('reset');
    $('.petition-bar__welcome-text').addClass('hidden-irrelevant');
  },

  completePrefill(prefillValues) {
    this.$('.petition-bar__field-container').addClass('form__group--prefilled');
    this.partialPrefill(prefillValues, []);
  },

  partialPrefill(prefillValues, fieldsToSkipPrefill) {
    if(!_.isObject(prefillValues)) { return; }
    fieldsToSkipPrefill = fieldsToSkipPrefill || [];
    this.$('.petition-bar__field-container input, select').each((ii, field) => {
      let $field = $(field);
      let name = $field.prop('name');
      if (prefillValues.hasOwnProperty(name) && fieldsToSkipPrefill.indexOf(name) === -1) {
        $field.val(prefillValues[name]);
      }
    });
  },

  formFieldCount() {
    return this.$('.petition-bar__field-container').length;
  },

  showFormClearer(member) {
    this.$().member.welcome_name
  }
};

module.exports = FormMethods;
