let ErrorDisplay = require('shared/show_errors');
let MobileCheck = require('member-facing/backbone/mobile_check');
const GlobalEvents = require('shared/global_events');

const ActionForm = Backbone.View.extend({

  el: 'form.action-form',
  HIDDEN_FIELDS: ['source', 'akid', 'referrer_id', 'bucket'],

  events: {
    'click .action-form__clear-form': 'clearForm',
    'ajax:success': 'handleSuccess',
    'ajax:error': 'handleFailure',
    'ajax:send': 'disableButton',
  },

  globalEvents: {
    'form:clear': 'clearForm',
    'form:step_change': 'handleStepChange',
  },

  // options: object with any of the following keys
  //    akid: the actionkitid (akid) to save with the user request
  //    source: the referring source to save
  //    outstandingFields: the names of step 2 form fields that aren't satisfied by
  //      the values in the member hash.
  //    member: an object with fields that will prefill the form
  //    referrer_id: if passed, submitted to the server in the form
  //    bucket: if passed, submitted to the server in the form
  //    location: a hash of location values inferred from the user's request
  //    skipPrefill: boolean, will not prefill if true
  initialize(options={}) {
    this.insertHiddenFields(options);
    if (!options.skipPrefill) {
      this.prefillAsPossible(options);
    }
    if (!MobileCheck.isMobile()) {
      this.selectizeCountry();
    }
    this.$submitButton = this.$('.action-form__submit-button');
    this.buttonText = this.$submitButton.text();
    GlobalEvents.bindEvents(this);
  },

  // prefills based on outstandingFields and member, returns true or false to indicate
  // the form can now be safely hidden from the user
  prefillAsPossible(options) {
    if (this.formCanAutocomplete(options.outstandingFields, options.member)) {
      this.completePrefill(options.member, options.location);
      if (this.formFieldCount() > 0) {
        this.showFormClearer(options.member);
      }
      this.$el.data('prefilled', true);
      return true
    } else {
      this.partialPrefill(options.member, options.location, options.outstandingFields);
      return false
    }
  },

  selectizeCountry() {
    this.$('.action-form__country-selector').selectize();
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
    $('.action-form__welcome-text').addClass('hidden-irrelevant');
    this.renameActionKitIdToReferringId();
    Backbone.trigger('sidebar:height_change');
  },

  completePrefill(prefillValues, unvalidatedPrefillValues) {
    this.$('.action-form__field-container').addClass('form__group--prefilled');
    this.partialPrefill(prefillValues, unvalidatedPrefillValues, []);

    // DESIRED BUT WEIRD BEHAVIOR - UNHIDE CHECKBOXES AND EMPTY FIELDS
    let $empties = this.$('.action-form__field-container').
                        find('input, textarea, select').
                        filter(function(ii, el){
                          let val = $(this).val();
                          return val === null || val.length === 0
                        });
    let $checkboxes = this.$('.action-form__field-container').find('.checkbox-label');
    $.merge($empties, $checkboxes).
         parents('.action-form__field-container').
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
    this.$('.action-form__field-container input, select').each((ii, field) => {
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
    return this.$('.action-form__field-container').length;
  },

  showFormClearer(member) {
    // don't bind to this.$ so it can be anywhere on the page
    $('.action-form__welcome-name').text(member.welcome_name);
    $('.action-form__welcome-text').removeClass('hidden-irrelevant');
  },

  insertHiddenFields(options) {
    for(var ii = 0; ii < this.HIDDEN_FIELDS.length; ii++) {
      let field = this.HIDDEN_FIELDS[ii];
      if(options[field] && this.$el) {
        this.insertHiddenInput(field, options[field], this.$el);
      }
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
  },

  handleSuccess(e, data){
    Backbone.trigger('form:submitted', e, data);
  },

  handleFailure(e, data) {
    ErrorDisplay.show(e, data);
    this.enableButton();
  },

  handleStepChange(step) {
    if (step <= 3) {
      this.enableButton();
    }
  },

  disableButton() {
    this.$submitButton.text(I18n.t('form.processing'));
    this.$submitButton.addClass('button--disabled');
  },

  enableButton() {
    this.$submitButton.text(this.buttonText);
    this.$submitButton.removeClass('button--disabled');
  },
});

module.exports = ActionForm;
