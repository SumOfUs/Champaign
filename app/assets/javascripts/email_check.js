$(document).ready(function(){
  $('[name="email_address"]').on('blur', function(){
    console.log('checking');
    var message_div = $('#mailcheck_message');
    $(this).mailcheck({
      suggested: function() {
        console.log('suggestions');
        message_div.removeClass('hidden');
        message_div.html('There are suggestions');
      },
      empty: function() {
        console.log('empty');
        message_div.addClass('hidden');
      }
    });
  });
});


