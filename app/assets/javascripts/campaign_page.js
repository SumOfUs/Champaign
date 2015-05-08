$(function() {
  $(".template_selector").change(function() {
    var template_id = $(this).val();
    $.ajax({
      url: '../templates/show_form/' + template_id,
      method: 'get'
    }).done(function(data) {
      $('#widget_location').html(data);
    })
  })
});
