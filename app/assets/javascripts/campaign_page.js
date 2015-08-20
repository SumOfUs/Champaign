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
    if($('#editor').length === 0){
      return false;
    }

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

  var configureToggle = function() {
    var $stateInput = $('.plugin-active-field');

    var handleClick = function(e){
      e.preventDefault();
      $('form.plugin-toggle').submit();
      $('.toggle-button').removeClass('btn-success');
      $(this).addClass('btn-success');
    };

    var handleSuccess = function(e,data){
      console.log('succes', data);
    };

    var handleError = function(xhr, status, error){
      console.log('error', status, error);
    };

    var updateState = function(){
      var state = !JSON.parse($stateInput.val());
      $stateInput.val(state);
    };

    $('.toggle-button').on('click', handleClick);

    $('form.plugin-toggle').on('ajax:before', updateState);
    $('form.plugin-toggle').on('ajax:success', handleSuccess);
    $('form.plugin-toggle').on('ajax:error', handleError);
  };

  var configureSelect2 = function(){
    $('.select2-container').select2({});
  }

  var initialize = function() {
    configureDropZone();
    configureQuillEditor();
    configureSelect2();
    configureToggle();
  };

  $.subscribe("campaign_page:has_loaded", initialize);

}());

