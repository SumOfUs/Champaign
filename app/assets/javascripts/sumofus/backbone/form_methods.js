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
    this.renameActionKitIdToReferringId();
  },

  completePrefill(prefillValues, unvalidatedPrefillValues) {
    this.$('.petition-bar__field-container').addClass('form__group--prefilled');
    this.partialPrefill(prefillValues, unvalidatedPrefillValues, []);
  },

  // prefillValues - an object mapping form names to prefill values
  // fieldsToSkipPrefill - a list of names of fields that were not
  //    satisfied when the form was validated with prefillValues
  // unvalidatedPrefillValues - values that were not passed through
  //    the form validator, so should be prefilled even if the field
  //    name comes up in fieldsToSkipPrefill.
  partialPrefill(prefillValues, unvalidatedPrefillValues = {}, fieldsToSkipPrefill = []) {
    if(!_.isObject(prefillValues)) { return; }
    fieldsToSkipPrefill = fieldsToSkipPrefill || [];
    this.$('.petition-bar__field-container input, select').each((ii, field) => {
      let $field = $(field);
      let name = $field.prop('name');
      if (unvalidatedPrefillValues.hasOwnProperty(name)) {
        $field.val(unvalidatedPrefillValues[name]);
      }
      if (prefillValues.hasOwnProperty(name) && fieldsToSkipPrefill.indexOf(name) === -1) {
        $field.val(prefillValues[name]);
      }
    });
  },

  formFieldCount() {
    return this.$('.petition-bar__field-container').length;
  },

  showFormClearer(plugin_type, member) {
    this.$(`.${plugin_type}-bar__welcome-name`).text(member.welcome_name);
    this.$(`.${plugin_type}-bar__welcome-text`).removeClass('hidden-irrelevant');
  },

  insertActionKitId(form_type, akid) {
    let $form;
    if(form_type == 'petition') {
      $form = $('.petition-bar__main').find('form')[0];
    } else if(form_type == 'fundraiser') {
      $form = $('.fundraiser-bar__step-panel').find('form')[0]
    }
    console.log(akid);

    if(akid) {
      if($form) {
        $('<input>').attr({
          type: 'hidden',
          name: 'akid',
          value: akid
        }).appendTo($form);
      }
    }
  },

  renameActionKitIdToReferringId() {
    let $action_kit_hidden = $('input[name="akid"]');
    if($action_kit_hidden) {
      $action_kit_hidden.attr('name', 'referring_akid');
    }
  }
};

module.exports = FormMethods;
