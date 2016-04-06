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
        ['para', ['ul', 'ol', 'paragraph']],
        ['color', ['color']],
        ['insert', ['link', 'picture', 'video']],
        ['view', ['fullscreen', 'codeview', 'help']]
      ],
      height: 280,
      fontSizes: ['8', '10', '11', '12', '14', '16', '20', '24', '36', '72'],
      codemirror: {
        theme: 'default',
        mode: "text/html",
        lineNumbers: true,
        tabMode: 'indent',
        lineWrapping: true
      }
    });
    $contentField = $('#page_content');

    $editor.summernote('fontSize', '16'); // default
    $editor.summernote('code', $contentField.val());

    updateContentBeforeSave = function(){
      var content = $editor.summernote('code');
      $contentField.val(content);
    };

    $.subscribe("wysiwyg:submit", updateContentBeforeSave);
  }

  $.subscribe("wysiwyg:setup", configureWysiwyg);
}());
