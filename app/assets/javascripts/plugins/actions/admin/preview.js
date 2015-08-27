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
    var plugin_id = $('.plugin.action').data('plugin-id'),
        url = ["/plugins/actions/", plugin_id, "/preview"].join('');

    $.get(url, function(resp) {
      $('.plugin-action-preview .content').html(resp)
    });
  };

  $.subscribe('plugin:action:preview:update', updatePreview);


  $('.plugin.action').on('ajax:success', function(){
    $.publish('plugin:action:preview:update');
  });

  $('.plugin.action').on('ajax:error', function(e, xhr,resp){
    //for debugging
    console.log(xhr, resp);
  });
});

