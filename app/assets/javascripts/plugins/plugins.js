$(function(){
  $('body').on('ajax:success', 'form.plugin-settings', function(event, data, status, xhr) {
    console.log("success", data);
    $(this).replaceWith(data);
  });

  $('body').on('ajax:error', 'form.plugin-settings', function(event, xhr, status, error) {
    console.log('errors', xhr.responseText);
    $(this).replaceWith(xhr.responseText);
  });

});

