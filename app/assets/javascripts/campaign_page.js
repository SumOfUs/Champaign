// This requests html for rendering different template layouts whenever a user toggles
// a different template to use in campaign creation
$(function() {
  $(".template_selector").change(function() {
    var template_id = $(this).val();
    $.ajax({
      url: '../templates/show_form/' + template_id,
      method: 'get'
    }).done(function(data) {
      $('#widget_location').html(data);
    })
  });

  // This controls adding new checkboxes to the petition form when it is present.
  var checkbox_count = 0;
  // We bind the event to the widget location div, then indicate that it should
  // only fire when the add-checkbox ID is clicked. This is because the add-checkbox
  // element doesn't exist on page load, but we're trying to create a handler for it already.
  $("#widget_location").on('click', '#add-checkbox', function(event){
    event.preventDefault();
    console.log('clicked');
    var checkbox_html = $('#checkbox-seed').html();
    var final_html = checkbox_html.replace(/{cb_number}/g, checkbox_count);
    $('#checkbox-container').append(final_html);
    checkbox_count++;
  });
});
