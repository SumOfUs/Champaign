$(document).ready(function(){
	//Dropzone.autoDiscover = false;

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

$(function(){

  //var clip = new ZeroClipboard();

  $('.campaign-images').on('click', 'img', function(e) {
    var $img = $(this);
		//clip.setText($img.attr('src'));
    ZeroClipboard.setData( "text/plain", "Copy me!" );
  });
});


