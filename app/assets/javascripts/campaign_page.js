(function(){

  var configureDropZone = function() {
    Dropzone.options.dropzone = {
      maxFilesize: 2,
      paramName: "image[content]",
      addRemoveLinks: false,
      previewsContainer: null,
      createImageThumbnails: true,

      init: function() {
        this.on("success", function(resp, data) {
          $('.campaign-images').append(data.html);
        });

        this.on("addedfiled", function(file) {
          this.removeFile(file);
        });
      }
    };
  }

  var configureQuillEditor = function() {
    var quillConfig = {
      theme: 'snow',
      modules: {
        'toolbar': { container: '#toolbar' },
        'link-tooltip': true
      }
    },

    quill = new Quill('#editor', quillConfig),
    $contentField = $('#campaign_page_content'),

    updateContentBeforeSave = function(){
      var content = quill.getHTML();
      $contentField.val(content);
    };

    quill.setHTML( $contentField.val() );

    $('form.edit_campaign_page').on('ajax:before', updateContentBeforeSave);
  }

  var initialize = function() {
    configureDropZone();
    configureQuillEditor();
  };

  $.subscribe("campaign_page:has_loaded", initialize);

}());

