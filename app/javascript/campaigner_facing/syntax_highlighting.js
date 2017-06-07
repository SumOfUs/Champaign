// This depends on codemirror and its modes being required in
// `app/assets/javascripts/application.js`
$(function() {
  $('.syntax-highlighting').each(function(idx, el) {
    var mode = $(el).data('highlight-mode') || 'htmlmixed';
    var cm = CodeMirror.fromTextArea(el, {
      mode: mode,
      theme: '3024-night',
    });
    $.subscribe('wysiwyg:submit', cm.save);
  });
});
