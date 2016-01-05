// This file adds error messages inline to forms.
// For it to work properly, you need to pass data from the controller like:
//   format.json { render json: {errors: link.errors, name: 'link'}, status: :unprocessable_entity }
// The name field is for if the form element names are prefixed, eg 'link[title]'
let ErrorDisplay = {

  show(e, data) {
    if (!e || !data || !data.responseText || data.status != 422) {
      return; // no reason to try if we dont have what we need
    }
    // use the relevant form if the event was a form submission
    let $form = ($(e.target) && $(e.target).length > 0) ? $(e.target) : $('form');
    let response = $.parseJSON(data.responseText);
    this.clearErrors($form);
    $.each(response.errors, (f, m) => { this.showError(f, m, $form, response) });
  },

  clearErrors($form) {
    $form.find('.has-error').removeClass('has-error');
    $form.find('.error-msg').remove();
  },

  showError(field_name, msgs, $form, response) {
    let $field = this.findField(field_name, $form, response);
    $field.addClass('has-error').parent().addClass('has-error');
    $field.parent().append(this.errorMsg(field_name, msgs));
    $field.on('focus', (e) => { this.hideError(e) })
  },

  errorMsg(field_name, msgs) {
    let msg = (typeof msgs === "string") ? msgs : msgs[0]
    let prefix = window.I18n ? I18n.t('errors.this_field') : 'This field';
    return `<div class='error-msg'>${prefix} ${msg}</div>`;
  },

  hideError(e) {
    $(e.target).removeClass('has-error').parent().removeClass('has-error');
    $(e.target).siblings('.error-msg').remove();
  },

  findField(field_name, $form, response) {
    if (response.name) {
      field_name = [response.name, '[', field_name, ']'].join('');
    }
    return $form.find("[name='" + field_name + "']");
  },
}

module.exports = ErrorDisplay
