$(function(){
  $('form.action').on('ajax:error', function(e, data){
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
    var showError = function(field_name, msgs, form) {
      field = form.find(`[name="${field_name}"]`);
      field.addClass('has-error').parent().addClass('has-error');
      field.after(errorMsg(field_name, msgs));
      field.on('focus', hideError)
    }
    $.each(errors, function(field_name, msgs){
      showError(field_name, msgs, $form);
    })
  });

  $('form.action').on('ajax:success', function(e, data){
    $('.post-action span.name').text(data.form_data.first_name);

    $(this).fadeOut(function(){
      $('.post-action').fadeIn('fast');
    });
  });
});


