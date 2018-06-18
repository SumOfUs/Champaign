import $ from 'jquery';
import I18n from 'champaign-i18n';
import React from 'react';
import { render } from 'react-dom';
import _ from 'lodash';
import Backbone from 'backbone';
import ErrorDisplay from '../../shared/show_errors';
import MobileCheck from './mobile_check';
import GlobalEvents from '../../shared/global_events';
import ComponentWrapper from '../../components/ComponentWrapper';
import ConsentComponent from '../../consent/ConsentComponent';
import ExistingMemberConsent from '../../consent/ExistingMemberConsent';
import {
  changeCountry,
  changeVariant,
  resetState,
  toggleModal,
} from '../../state/consent';
import { resetMember } from '../../state/member/reducer';

const ActionForm = Backbone.View.extend({
  el: 'form.action-form',
  HIDDEN_FIELDS: [
    'source',
    'akid',
    'referrer_id',
    'rid',
    'bucket',
    'referring_akid',
  ],

  events: {
    'click .action-form__submit-button': 'onClickSubmit',
    'click .action-form__clear-form': 'clearForm',
    'change .action-form__dropdown[name="country"]': 'handleCountryChange',
    'ajax:success': 'handleSuccess',
    'ajax:error': 'handleFailure',
    'ajax:send': 'disableButton',
  },

  globalEvents: {
    'form:clear': 'clearForm',
    'form:step_change': 'handleStepChange',
    'form:submit_action_form': 'submitForm',
  },

  // options: object with any of the following keys
  //    akid: the actionkitid (akid) to save with the user request
  //    source: the referring source to save
  //    outstandingFields: the names of step 2 form fields that aren't satisfied by
  //      the values in the member hash.
  //    member: an object with fields that will prefill the form
  //    referring_akid: if passed, submitted to the server in the form
  //    referrer_id: if passed, submitted to the server in the form
  //    bucket: if passed, submitted to the server in the form
  //    location: a hash of location values inferred from the user's request
  //    skipPrefill: boolean, will not prefill if true
  //    async: when true the form will validate by default.
  //      To submit trigger event `form:submit_action_form`
  initialize(options = {}) {
    this.store = window.champaign.store;
    this.member = options.member;
    this.variant = options.variant || 'simple';
    this.async = options.async || false;
    this.insertHiddenFields(options);
    this.applyDisplayModeToFields(options.member);
    this.url = this.$el.attr('action');
    if (!options.skipPrefill) {
      this.prefillAsPossible(options);
    }
    if (!MobileCheck.isMobile()) {
      this.selectizeDropdowns();
    }
    this.$submitButton = this.$('.action-form__submit-button');
    this.buttonText = this.$submitButton.text();
    this.setupState();
    this.enableGDPRConsent();
    GlobalEvents.bindEvents(this);
  },

  defaultAction() {
    if (this.isConsentNeededForExistingMember() || this.async) {
      return 'validate';
    }
    return 'submit';
  },

  state() {
    if (!this.store) return null;
    return this.store.getState();
  },

  setupState() {
    this.store.dispatch(changeVariant(this.variant));
  },

  isMemberPresent() {
    return !_.isEmpty(this.member);
  },

  isConsentNeededForExistingMember() {
    const { member, consent } = this.state();
    return member && consent.isRequiredExisting;
  },

  resetState() {
    if (this.store) {
      this.store.dispatch(resetState());
      this.store.dispatch(changeVariant(this.variant));
    }
  },

  submitForm() {
    _.delay(() => this.$el.submit(), 300);
  },

  handleCountryChange(event) {
    if (this.store) {
      this.store.dispatch(changeCountry(event.target.value) || null);
    }
  },

  onClickSubmit(event) {
    if (this.defaultAction() === 'validate') {
      event.preventDefault();
      event.stopPropagation();
      this.validateForm().then(() => {
        if (this.isConsentNeededForExistingMember()) {
          this.store.dispatch(toggleModal(true));
        } else {
          Backbone.trigger('form:validated');
        }
      });
    }
  },

  validateForm() {
    return $.post(`${this.url}/validate`, this.$el.serialize()).then(
      undefined,
      data => this.handleFailure({ target: this.$el }, data)
    );
  },

  // Looks at the display-mode for each field and hides them accordingly
  applyDisplayModeToFields(member) {
    if (this.isMemberPresent()) {
      this.$el.find('[data-display-mode="new_members_only"]').hide(0);
    } else {
      this.$el.find('[data-display-mode="recognized_members_only"]').hide(0);
    }
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
      return true;
    } else {
      this.partialPrefill(
        options.member,
        options.location,
        options.outstandingFields
      );
      return false;
    }
  },

  selectizeDropdowns() {
    this.$(
      '.action-form__country-selector, .action-form__dropdown'
    ).selectize();
  },

  clearFormErrors() {
    ErrorDisplay.clearErrors(this.$('form'));
  },

  formCanAutocomplete(outstandingFields, member) {
    return (
      _.isArray(outstandingFields) &&
      outstandingFields.length === 0 &&
      (this.formFieldCount() === 0 || _.isObject(member))
    );
  },

  clearForm() {
    this.store.dispatch(resetMember());
    const $fields_holder = this.$('.form__group--prefilled');
    $fields_holder.removeClass('form__group--prefilled');
    $fields_holder
      .find(
        'input[type="text"], input[type="email"], input[type="tel"], select'
      )
      .val('')
      .trigger('change');
    $fields_holder.find('input[type="checkbox"]').attr('checked', false);

    $fields_holder.find('select').each((ii, el) => {
      el.selectedIndex = -1;
    });
    $fields_holder.find('.selectized').each((ii, el) => {
      el.selectize.clear();
    });
    $fields_holder.parents('form').trigger('reset');
    $('.action-form__welcome-text').addClass('hidden-irrelevant');
    this.renameActionKitIdToReferringId();
    this.member = {};
    this.resetState();
    this.enableGDPRConsent();
    Backbone.trigger('sidebar:height_change');
  },

  completePrefill(prefillValues, unvalidatedPrefillValues) {
    this.$('.action-form__field-container').addClass('form__group--prefilled');
    this.partialPrefill(prefillValues, unvalidatedPrefillValues, []);

    // DESIRED BUT WEIRD BEHAVIOR - unhide empty fields,
    //   radio buttons, check boxes, and instructions
    const $empties = this.$('.action-form__field-container')
      .find('input, textarea, select')
      .filter(function(ii, el) {
        const val = $(this).val();
        return val === null || val.length === 0;
      });
    const $checkboxes = this.$('.action-form__field-container').find(
      '.checkbox-label, .radio-container, .form__instruction'
    );
    $.merge($empties, $checkboxes)
      .parents('.action-form__field-container')
      .removeClass('form__group--prefilled');
  },

  // prefillValues - an object mapping form names to prefill values
  // fieldsToSkipPrefill - a list of names of fields that were not
  //    satisfied when the form was validated with prefillValues
  // unvalidatedPrefillValues - values that were not passed through
  //    the form validator, so should be prefilled even if the field
  //    name comes up in fieldsToSkipPrefill.
  partialPrefill(
    prefillValues,
    unvalidatedPrefillValues = {},
    fieldsToSkipPrefill = []
  ) {
    if (!_.isObject(prefillValues)) {
      return;
    }
    fieldsToSkipPrefill = fieldsToSkipPrefill || [];
    this.$('input[type=text], input[type=email], input[type=tel], select').each(
      (ii, field) => {
        const $field = $(field);
        const name = $field.prop('name');
        if (unvalidatedPrefillValues.hasOwnProperty(name)) {
          // weird edge case handling - if the name field is country and the country code is
          // the 'Reserved' country code, don't prefill since it's not a real code.
          const isUnknownCountry =
            name.match('country') && unvalidatedPrefillValues[name] == 'RD';
          if (!isUnknownCountry) {
            $field.val(unvalidatedPrefillValues[name]).trigger('change');
          }
        }
        if (
          prefillValues.hasOwnProperty(name) &&
          fieldsToSkipPrefill.indexOf(name) === -1
        ) {
          $field.val(prefillValues[name]).trigger('change');
        }
      }
    );
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
    for (let ii = 0; ii < this.HIDDEN_FIELDS.length; ii++) {
      const field = this.HIDDEN_FIELDS[ii];
      if (options[field] && this.$el) {
        this.insertHiddenInput(field, options[field], this.$el);
      }
    }

    if (this.consentNeeded) {
      this.insertHiddenInput('consented', options.member.consented, this.$el);
    }
  },

  insertHiddenInput(name, value, element) {
    $('<input>')
      .attr({
        type: 'hidden',
        name: name,
        value: value,
      })
      .appendTo(element);
  },

  renameActionKitIdToReferringId() {
    const $action_kit_hidden = $('input[name="akid"]');
    if ($action_kit_hidden) {
      $action_kit_hidden.attr('name', 'referring_akid');
    }
  },

  handleSuccess(e, data) {
    // FIXME: we should return consistently from the backend
    // FIXME: we should not rely on mutating function arguments of unkown type
    if (typeof data === 'object') data.petitionForm = this.formValues();
    Backbone.trigger('form:submitted', e, data);
  },

  formValues() {
    const values = {};
    this.$(
      'input[type=text], input[type=email], input[type=tel], textarea, select'
    ).each((i, input) => {
      values[input.name] = this.$(input).val();
    });

    this.$('input[type=checkbox]').each((i, input) => {
      values[input.name] = input.checked ? '1' : '0';
    });

    this.$('input[type=radio]:checked').each((i, input) => {
      values[input.name] = this.$(input).val();
    });
    return values;
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

  enableGDPRConsent() {
    if (this.gdprContainer) return;
    this.gdprContainer = document.createElement('div');
    this.$submitButton.before(this.gdprContainer);

    render(
      <ComponentWrapper store={window.champaign.store} locale={I18n.locale}>
        <ConsentComponent />
        <ExistingMemberConsent />
      </ComponentWrapper>,
      this.gdprContainer
    );
  },
});

export default ActionForm;
