import GlobalEvents from '../shared/global_events';

const FormElementCreator = Backbone.View.extend({
  GENERIC_NAME: 'instruction', // since instruction fields are the only type with no need for a name
  GENERIC_LABEL: 'hidden', // since hidden fields are the only type with no need for a label

  roles: [
    'defaultValue',
    'defaultRevealer',
    'choices',
    'label',
    'name',
    'manyChoices',
  ],
  modes: {
    default: ['defaultRevealer', 'label', 'name', 'requirable'],
    hidden: ['defaultValue', 'name'],
    instruction: ['label'],
    choice: ['choices', 'label', 'name', 'requirable'],
    dropdown: ['manyChoices', 'label', 'name', 'requirable', 'defaultRevealer'],
  },

  events: {
    'change #form_element_data_type': 'changeFormMode',
  },

  globalEvents: {
    'collection:element_added': 'resetAfterSubmission',
  },

  initialize() {
    this.changeFormMode({ target: this.$('#form_element_data_type') });
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
    for (var role of this.roles) {
      let $el = this.$(`[data-editor-role=${role}]`);
      $el.toggleClass('hidden-closed', !this.hasField(role, mode));
    }
  },

  setModeValues(mode) {
    if (!this.hasField('choices', mode)) {
      this.resetChoices();
    }
    if (!this.hasField('defaultValue', mode)) {
      this.resetDefaultValue();
    }
    if (!this.hasField('requirable', mode)) {
      this.resetRequired();
    }
    if (this.hasField('name', mode)) {
      this.setNameAwayFromGeneric();
    } else {
      this.setNameToGeneric();
    }
    if (this.hasField('label', mode)) {
      this.setLabelAwayFromGeneric();
    } else {
      this.setLabelToGeneric();
    }
  },

  hasField(role, mode) {
    return this.modes[mode].indexOf(role) > -1;
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
    this.$('.form-element__many-choices-field textarea').val('');
    this.$('.form-element__choice-fields').append(
      this.$copyableChoiceField.clone()
    );
  },

  ensureCopyableChoiceField() {
    if (this.$copyableChoiceField === undefined) {
      this.$copyableChoiceField = this.$('.form-element__choice-field')
        .first()
        .clone();
      this.$copyableChoiceField.find('input').val('');
    }
  },
});

export default FormElementCreator;
