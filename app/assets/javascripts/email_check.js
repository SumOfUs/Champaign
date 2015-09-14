$(document).ready(function(){
  $('[name="email_address"]').on('blur', function(){
    var message_div = $('#mailcheck_message');
    $(this).mailcheck({
      suggested: function(element, suggestion) {
        message_div.html('<em>Did you mean ' + suggestion['full'] + '?</em>');
        message_div.removeClass('hidden');
      },
      empty: function() {
        message_div.addClass('hidden');
      }
    });
  });
});


