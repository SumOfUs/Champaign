//= require codemirror
//= require codemirror/modes/htmlmixed
//= require codemirror/modes/xml
//= require codemirror/modes/javascript
//= require codemirror/modes/css

$(function(){
  $('.syntax-highlighting').each(function(idx, el){
    var mode = $(el).data('highlight-mode') || 'htmlmixed';
    var cm = CodeMirror.fromTextArea(el, {
      mode: mode,
      theme: '3024-night'
    });
    $.subscribe('wysiwyg:submit', cm.save);
  });
});
