const GlobalEvents = require('shared/global_events');

const FormElementCreator = Backbone.View.extend({

  GENERIC_NAME: 'instruction', // since instruction fields are the only type with no need for a name
  GENERIC_LABEL: 'hidden', // since hidden fields are the only type with no need for a label

  modes: {
    default:     { defaultValue: false, defaultRevealer: true,  choices: false, label: true, name: true,  requirable: true },
    hidden:      { defaultValue: true,  defaultRevealer: false, choices: false, label: false, name: true,  requirable: false },
    instruction: { defaultValue: false, defaultRevealer: false, choices: false, label: true, name: false, requirable: false },
    choice:      { defaultValue: false, defaultRevealer: false, choices: true,  label: true, name: true,  requirable: true },
  },

  events: {
    'change #form_element_data_type': 'changeFormMode',
    'click .form-element__remove-choice': 'removeChoice',
    'click .form-element__add-choice': 'addChoice',
  },

  globalEvents: {
    'collection:element_added': 'resetAfterSubmission',
  },

  initialize() {
    this.changeFormMode({target: this.$('#form_element_data_type')});
    GlobalEvents.bindEvents(this);
  },

  changeFormMode(e) {
    let mode = this.$(e.target).val();
    if (!this.modes.hasOwnProperty(mode)) {
      mode = 'default';
    }
    this.mode = mode;
    this.setModeVisuals(mode);
    this.setModeValues(mode);
  },

  resetAfterSubmission() {
    this.setModeVisuals(this.mode);
    this.setModeValues(this.mode);
  },

  setModeVisuals(mode) {
    for (var role in this.modes[mode]) {
      let $el = this.$(`[data-editor-role=${role}]`);
      $el.toggleClass('hidden-closed', !this.modes[mode][role]);
    }
  },

  setModeValues(mode) {
    if (!this.modes[mode].choices) {
      this.resetChoices();
    }
    if (!this.modes[mode].defaultValue) {
      this.resetDefaultValue();
    }
    if (!this.modes[mode].requirable) {
      this.resetRequired();
    }
    if (this.modes[mode].name) {
      this.setNameAwayFromGeneric();
    } else {
      this.setNameToGeneric();
    }
    if (this.modes[mode].label) {
      this.setLabelAwayFromGeneric();
    } else {
      this.setLabelToGeneric();
    }
  },

  setNameToGeneric() {
    this.$('input#form_element_name').val(this.GENERIC_NAME);
  },

  setNameAwayFromGeneric() {
    let $nameField = this.$('input#form_element_name');
    if ($nameField.val() === this.GENERIC_NAME) {
      $nameField.val('');
    }
  },

  setLabelToGeneric() {
    this.$('input#form_element_label').val(this.GENERIC_LABEL);
  },

  setLabelAwayFromGeneric() {
    let $nameField = this.$('input#form_element_label');
    if ($nameField.val() === this.GENERIC_LABEL) {
      $nameField.val('');
    }
  },

  resetRequired() {
    this.$('input#form_element_required').prop('checked', false);
  },

  resetDefaultValue() {
    this.$('input#form_element_default_value').val('');
  },

  resetChoices() {
    this.ensureCopyableChoiceField();
    this.$('.form-element__choice-fields').html('');
    this.$('.form-element__choice-fields').append(this.$copyableChoiceField.clone());
  },

  ensureCopyableChoiceField() {
    if (this.$copyableChoiceField === undefined) {
      this.$copyableChoiceField = this.$('.form-element__choice-field').first().clone();
      this.$copyableChoiceField.find('input').val('');
    }
  },

  addChoice() {
    this.ensureCopyableChoiceField();
    this.$('.form-element__choice-fields').append(this.$copyableChoiceField.clone());
  },

  removeChoice(e) {
    let $choiceField = this.$(e.target).parents('.form-element__choice-field');
    if (this.$('.form-element__choice-fields').children().length > 1) {
      $choiceField.remove();  
    } else {
      $choiceField.find('input').val('');
    }
  },

});

module.exports = FormElementCreator;
