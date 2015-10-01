(function(){
  var configureDropZone = function() {
    Dropzone.options.dropzone = {
      maxFilesize: 2,
      paramName: "image[content]",
      addRemoveLinks: false,
      previewsContainer: null,
      createImageThumbnails: true,

      init: function() {
        this.on("success", function(resp, html) {
          $('.campaign-images').append(html);
          $('.campaign-images .notice').hide();
        });

        this.on("addedfiled", function(file) {
          this.removeFile(file);
        });
      }
    };
  };

  var bindHandlers = function() {
    $('.campaign-images').on('ajax:success', "a[data-method=delete]", function(){
      $(this).parents('.image-thumb').fadeOut();
    });
  };

  var checkAnyImages = function() {
    if( $('.campaign-images img').length == 0) {
      $('.campaign-images').hide();
    }
  };

  var initialize = function() {
    configureDropZone();
    bindHandlers();
  };

  $.subscribe("dropzone:setup", initialize);
}());

