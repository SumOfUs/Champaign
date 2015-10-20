(function(){
  var configureDropZone = function() {
    Dropzone.options.dropzone = {
      maxFilesize: 2,
      paramName: "image[content]",
      addRemoveLinks: false,
      previewsContainer: null,
      createImageThumbnails: true,
      previewTemplate: document.querySelector('#dropzone-preview-template').innerHTML,

      init: function() {
        this.on("success", function(resp, html) {
          $('.campaign-images .notice').hide();
          $('.dz-success').replaceWith(html);
          var id = $(html).data('image-id');
          $.publish('image:success', [resp, id, html]);
        });

        this.on("addedfiled", function(file) {
          this.removeFile(file);
        });
      }
    };
  };

  var bindHandlers = function() {
    $('.campaign-images').on('ajax:success', "a[data-method=delete]", function(){
      $(this).parents('.dz-preview').fadeOut();
      var imageId = $(this).parents('[data-image-id]').data('image-id');
      $.publish('image:destroyed', imageId)
    });
  };

  var initialize = function() {
    configureDropZone();
    bindHandlers();
  };

  $.subscribe("dropzone:setup", initialize);
}());

