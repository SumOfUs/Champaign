$(function(){
  $('form.action').on('ajax:error', window.Champaign.showErrors);

  $('form.action').on('ajax:success', function(e, data){
    $('.post-action span.name').text(data.form_data.first_name);

    $(this).fadeOut(function(){
      $('.post-action').fadeIn('fast');
    });
  });
});


