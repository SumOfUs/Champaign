$(function(){
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
});

