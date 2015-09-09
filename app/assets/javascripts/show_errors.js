console.log("yoooooo")
window.Champaign = window.Champaign || {};
window.Champaign.showErrors = function(e, data) {

  if (!e || !data || !e.target || !data.responseText || $(e.target).length == 0) {
    return; // no reason to try if we dont have what we need
  }
  $form = $(e.target);
  errors = $.parseJSON(data.responseText);

  var errorMsg = function(field_name, msgs) {
    var name = field_name.replace('_', ' ')
    return `<div class="error-msg">${name} ${msgs[0]}</div>`
  }

  var hideError = function(e) {
    $(this).removeClass('has-error').parent().removeClass('has-error');
    $(this).siblings('.error-msg').remove();
  }

  var showError = function(field_name, msgs) {
    field = $form.find(`[name="${field_name}"]`);
    field.addClass('has-error').parent().addClass('has-error');
    field.after(errorMsg(field_name, msgs));
    field.on('focus', hideError)
  }

  $.each(errors, showError);
}

