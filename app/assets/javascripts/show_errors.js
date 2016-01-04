// This file adds error messages inline to forms.
// For it to work properly, you need to pass data from the controller like:
//   format.json { render json: {errors: link.errors, name: 'link'}, status: :unprocessable_entity }
// The name field is for if the form element names are prefixed, eg 'link[title]'

// this is ripe for a refactor to use the event system, and could be a backbone view too

window.Champaign = window.Champaign || {};
window.Champaign.showErrors = function(e, data) {

  if (!e || !data || !data.responseText || data.status != 422) {
    return; // no reason to try if we dont have what we need
  }

  // use the relevant form if the event was a form submission
  $form = ($(e.target) && $(e.target).length > 0) ? $(e.target) : $('form');
  response = $.parseJSON(data.responseText);

  var errorMsg = function(field_name, msgs) {
    var msg = (typeof msgs === "string") ? msgs : msgs[0]
    var prefix = window.I18n ? I18n.t('errors.this_field') : 'This field';
    return ["<div class='error-msg'>", prefix, " ", msg, "</div>"].join('');
  }

  var clearErrors = function() {
    $form.find('has-error').removeClass('has-error');
    $form.find('.error-msg').remove();
  }

  var hideError = function(e) {
    $(this).removeClass('has-error').parent().removeClass('has-error');
    $(this).siblings('.error-msg').remove();
  }

  var findField = function(field_name) {
    if (response.name) {
      field_name = [response.name, '[', field_name, ']'].join('');
    }
    return $form.find("[name='" + field_name + "']");
  }

  var showError = function(field_name, msgs) {
    field = findField(field_name);
    field.addClass('has-error').parent().addClass('has-error');
    field.parent().append(errorMsg(field_name, msgs));
    field.on('focus', hideError)
  }

  clearErrors();
  $.each(response.errors, showError);
}

