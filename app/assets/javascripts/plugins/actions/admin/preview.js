$(function(){


  var updatePreview = function(){
    console.log('update preview');
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
});
