$(function(){
  $('form.action').on('ajax:error', function(e, data){
    // TODO
    // Handle errors
    console.log("Error");
  });

  $('form.action').on('ajax:success', function(e, data){
    $('.post-action span.name').text(data.form_data.first_name);

    $(this).fadeOut(function(){
      $('.post-action').fadeIn('fast');
    });
  });
});
