$(function(){
  window.incrementShareCount = function(shareId) {
    $("form[data-id=" + shareId + "]").submit()
  };

  var handleShare = function(e) {
    e.preventDefault();
    var url = $(this).attr('href'),
        shareId = $(this).data('id');

    FB.ui({
      method: 'share',
      href: url,
    }, function(response){
      incrementShareCount(shareId);
    });
  };

  $('body').on('click', '.preview-facebook-share', handleShare);
});

