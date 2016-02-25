(function(){
  var configureWysiwyg = function() {
    var $editor = $('#summernote');
    if($editor.length === 0){
      return false;
    }

    $editor.summernote({
      toolbar: [
        ['style', ['bold', 'italic', 'underline', 'clear']],
        ['font', ['fontname', 'fontsize']],
        ['para', ['paragraph']],
        ['color', ['color']],
        ['insert', ['link', 'picture', 'video']],
        ['view', ['fullscreen', 'codeview', 'help']]
      ],
      fontSizes: ['8', '10', '11', '12', '14', '16', '20', '24', '36', '72'],
    });
    $contentField = $('#page_content'),

    updateContentBeforeSave = function(){
      var content = $editor.summernote('code');
      $contentField.val(content);
    };

    $editor.summernote('code', $contentField.val());

    $.subscribe("wysiwyg:submit", updateContentBeforeSave);
  }

  $.subscribe("wysiwyg:setup", configureWysiwyg);
}());
