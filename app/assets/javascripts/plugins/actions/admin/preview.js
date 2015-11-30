$(function(){

  var fixPreviewElement = function(){
    /*
     *
     * NOTE
     * This function is currently not invoked.
     * The plan is to have the preview div fix itself to view
     * so it remains visible as the user scrolls down the page.
     *
     */

    var $preview =  $('.plugin-action-preview');

    var originalPosition = $preview.offset(),
        originalTop = originalPosition.top;

    var handleSroll = function(){
      var css = {position: 'fixed', top: "0px" };
      if($(window).scrollTop() >= originalTop){
        $preview.css(css);
      } else {
        $preview.css({position: 'static'});
      }
    };

    $(window).scroll(handleSroll);
  };

  var updatePreview = function(){
    $('.plugin.action').each(function(ii, el){
      var $el = $(el);
        plugin_id = $el.data('plugin-id'),
        url = ["/plugins/actions/", plugin_id, "/preview"].join('');

      $.get(url, function(resp) {
        $el.find('.plugin-action-preview .content').html(resp)
      });
    });
  };

  if ($('.plugin-action-preview .content').length > 0) {
    $.subscribe('plugin:action:preview:update', updatePreview);
    $.subscribe('page:saved', updatePreview);
  }

  $('.plugin.action').on('ajax:success', function(){
    $.publish('plugin:action:preview:update');
  });

  $('.plugin.action').on('ajax:error', function(e, xhr,resp){
    //for debugging
    console.log(xhr, resp);
  });
});

(function(){
  var bindCaretToggle = function() {
    $('[data-toggle="collapse"]').on('click', function(e){
      $(this).toggleClass('open')
    })
  };

  $.subscribe('plugin:action:loaded', bindCaretToggle);
}());

