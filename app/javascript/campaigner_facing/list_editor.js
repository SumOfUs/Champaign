const ListEditor = Backbone.View.extend({
  events: {
    'click .form-element__remove-choice': 'removeChoice',
    'click .form-element__add-choice': 'addChoice',
  },

  ensureCopyableChoiceField() {
    if (this.$copyableChoiceField === undefined) {
      this.$copyableChoiceField = this.$('.form-element__choice-field')
        .first()
        .clone();
      this.$copyableChoiceField.find('input').val('');
    }
  },

  addChoice() {
    this.ensureCopyableChoiceField();
    this.$('.form-element__choice-fields').append(
      this.$copyableChoiceField.clone()
    );
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

export default ListEditor;
