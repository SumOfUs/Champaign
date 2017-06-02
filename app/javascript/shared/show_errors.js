// This file adds error messages inline to forms.
// For it to work properly, you need to pass data from the controller like:
//   format.json { render json: {errors: link.errors, name: 'link'}, status: :unprocessable_entity }
// The name field is for if the form element names are prefixed, eg 'link[title]'
export default {
  show(e, data) {
    if (!e || !data || !data.responseText || data.status != 422) {
      return; // no reason to try if we dont have what we need
    }
    // use the relevant form if the event was a form submission.
    // otherwise, search in all the forms on the page.
    let $form = $(e.target) && $(e.target).length ? $(e.target) : $('form');
    let response = $.parseJSON(data.responseText);
    ErrorDisplay.clearErrors($form);
    $.each(response.errors, (f, m) => {
      ErrorDisplay.showError(f, m, $form, response);
    });
  },

  clearErrors($form) {
    $form.find('.has-error').removeClass('has-error');
    $form.find('.error-msg').remove();
  },

  showError(field_name, msgs, $form, response) {
    let $field = ErrorDisplay.findField(field_name, $form, response);
    $field.addClass('has-error').parent().addClass('has-error');
    $field.parent().append(ErrorDisplay.errorMsg(field_name, msgs));
    $field.on('change', e => {
      ErrorDisplay.hideError(e);
    });
  },

  errorMsg(field_name, msgs) {
    let msg = typeof msgs === 'string' ? msgs : msgs[0];
    let prefix = window.I18n ? I18n.t('errors.this_field') : 'The field';
    return `<div class='error-msg'>${prefix} ${msg}</div>`;
  },

  hideError(e) {
    $(e.target).removeClass('has-error').parent().removeClass('has-error');
    $(e.target).siblings('.error-msg').remove();
    $(e.target).parent('.error-msg').remove();
  },

  findField(field_name, $form, response) {
    if (response.name) {
      field_name = [response.name, '[', field_name, ']'].join('');
    }
    var $field = $form.find(`[name="${field_name}"]`);
    if (!$field.length) {
      $field = $form.find(':submit').prev();
    } else if (
      $field.attr('type') === 'radio' &&
      $field.parents('.radio-container').length
    ) {
      return $field.parents('.radio-container');
    }
    return $field;
  },
};
