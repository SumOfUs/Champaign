$(document).ready(function(){
  $('.mailcheck').on('blur', function(){
    var $target = $(this);
    var $message_div = $target.parent().find('.mailcheck-message');
    if( $message_div.length === 0) {
      $target.after('<div class="mailcheck-message"></div>');
      $message_div = $target.parent().find('.mailcheck-message');
    }
    $target.mailcheck({
      suggested: function(element, suggestion) {
        $message_div.html('<em>Did you mean ' + suggestion['full'] + '?</em> - <a href="javascript:;" id="change_email">Change</a>');
        $('#change_email').on('click', function(){
          $target.val(suggestion['full'])
          $message_div.addClass('hidden');
        });
        $message_div.removeClass('hidden');
      },
      empty: function() {
        $message_div.addClass('hidden');
      }
    });
  });
});


