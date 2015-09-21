$(document).ready(function(){

  // I think I should just start using react or backbone for stuff.

  $('.checks-top').each(function(ii, el){
    $el = $(el);
    $( window ).on('scroll', function(){
      var position = $(window).scrollTop();
      if (position == 0) {
        $el.addClass('checks-top--at-top');
      } else {
        $el.removeClass('checks-top--at-top');
      }
    });
  });


});
