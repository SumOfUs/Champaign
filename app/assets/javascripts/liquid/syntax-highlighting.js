//= require codemirror
//= require codemirror/modes/htmlmixed
//= require codemirror/modes/xml
//= require codemirror/modes/javascript
//= require codemirror/modes/css

$(function(){
  $('.syntax-highlighting').each(function(idx, el){
    console.log(el)
    CodeMirror.fromTextArea(el, {
      mode: 'htmlmixed',
      theme: '3024-night'
    });
  });
});
