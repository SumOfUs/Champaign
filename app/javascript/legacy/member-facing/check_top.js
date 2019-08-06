$(document).ready(function() {
  $('.checks-top').each(function(ii, el) {
    let $el = $(el);
    if ($('.mobile-indicator').is(':visible')) {
      return;
    }
    $(window).on('scroll', function() {
      var position = $(window).scrollTop();
      if (position == 0) {
        $el.addClass('checks-top--at-top');
      } else {
        $el.removeClass('checks-top--at-top');
      }
    });
  });
});
