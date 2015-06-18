// This requests html for rendering different template layouts whenever a user toggles
// a different template to use in campaign creation
$(function() {
  $("#template_id").change(function() {
    var template_id = $(this).val();
    $.ajax({
      url: '/templates/show_form/' + template_id,
      method: 'get'
    }).done(function(data) {
      $('#widget_location').html(data);
    })
  });

  var widget_location = $('#widget_location');

  // This controls adding new checkboxes to the petition form when it is present.
  var checkbox_count = 0;
  // We bind the event to the widget location div, then indicate that it should
  // only fire when the add-checkbox ID is clicked. This is because the add-checkbox
  // element doesn't exist on page load, but we're trying to create a handler for it already.
  widget_location.on('click', '#add_checkbox', function(event){
    event.preventDefault();
    var checkbox_html = $('#checkbox_seed').html();

    // This replaces the placeholder 'cb_number' section in the checkbox we're pulling out
    // with the current inline number to be used for the checkbox. So for instance, the first
    // checkbox which is placed on the page will be in [widget][checkboxes][0][label],
    // while the second will be in [widget][checkboxes][1][label] to differentiate them
    // when they're saved in the database.
    var final_html = checkbox_html.replace(/{cb_number}/g, checkbox_count);
    $('#checkbox_container').append(final_html);
    checkbox_count++;
  });

  widget_location.on('click', '#add_textarea', function(event){
    event.preventDefault();
    var textarea_html = $('#textarea_seed').html();
    var final_html = textarea_html.replace('[placeholder]', '');
    $('#textarea_container').html(final_html);
  });

  $('#action-button').on('click', function(event){
    //Don't actually submit anything
    event.preventDefault();
    $.ajax({
      url: '/campaign_pages/sign/',
      method: 'post',
      success: function(data, textStatus, jqXHR) {
        var redirect_location = $('#redirect-location').html();
        if(redirect_location != '') {
          window.location.href = redirect_location;
        }
      }
    });
  });
});
