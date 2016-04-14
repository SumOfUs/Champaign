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
    $fields_holder.find('input[type="text"], input[type="email"], input[type="tel"], select').val('');
    $fields_holder.find('input[type="checkbox"]').attr('checked', false);

    $fields_holder.find('select').each((ii, el)=>{ el.selectedIndex = -1; });
    $fields_holder.find('.selectized').each((ii, el)=>{ el.selectize.clear(); });
    $fields_holder.parents('form').trigger('reset');
    $('.petition-bar__welcome-text').addClass('hidden-irrelevant');
    this.renameActionKitIdToReferringId();
    this.policeHeights();
  },

  completePrefill(prefillValues, unvalidatedPrefillValues) {
    this.$('.petition-bar__field-container').addClass('form__group--prefilled');
    this.partialPrefill(prefillValues, unvalidatedPrefillValues, []);

    // DESIRED BUT WEIRD BEHAVIOR - UNHIDE CHECKBOXES AND EMPTY FIELDS
    let $empties = this.$('.petition-bar__field-container').
                        find('input, textarea, select').
                        filter(function(){
                          return $(this).val().length === 0
                        });
    let $checkboxes = this.$('.petition-bar__field-container').find('.checkbox-label');
    $.merge($empties, $checkboxes).
         parents('.petition-bar__field-container').
         removeClass('form__group--prefilled');
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
        // weird edge case handling - if the name field is country and the country code is
        // the 'Reserved' country code, don't prefill since it's not a real code.
        let isUnknownCountry = (name.match('country') && unvalidatedPrefillValues[name] == 'RD')
        if (!isUnknownCountry) {
          $field.val(unvalidatedPrefillValues[name]);
        }
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

  insertActionKitId(akid) {
    let $form = this.$('form.action');

    if(akid && $form) {
      this.insertHiddenInput('akid', akid, $form)
    }
  }
  ,

  insertSource(source) {
    let $form = this.$('form.action');

    if(source && $form) {
      this.insertHiddenInput('source', source, $form)
    }
  },

  insertHiddenInput(name, value, element) {
    $('<input>').attr({
      type: 'hidden',
      name: name,
      value: value
    }).appendTo(element);
  },

  renameActionKitIdToReferringId() {
    let $action_kit_hidden = $('input[name="akid"]');
    if($action_kit_hidden) {
      $action_kit_hidden.attr('name', 'referring_akid');
    }
  }
};

module.exports = FormMethods;
