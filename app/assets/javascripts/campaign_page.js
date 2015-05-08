$(function() {
  $(".template_selector").change(function() {
    var template_id = $(this).val()
    $.ajax({
      url: '../templates/show_form',
      data: {
        "template_id": template_id,
        "language": $("#campaign_page_language").val(),
        "title": $("#campaign_page_title").val()
      }
    }).done(function() {
      console.log('done');
    })
  })
})
