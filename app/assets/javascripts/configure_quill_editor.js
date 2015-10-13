(function(){
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
    $contentField = $('#page_content'),

    updateContentBeforeSave = function(){
      var content = quill.getHTML();
      $contentField.val(content);
    };

    quill.setHTML( $contentField.val() );

    $.subscribe("quill_editor:submit", updateContentBeforeSave);
  }

  $.subscribe("quill_editor:setup", configureQuillEditor);
}());

