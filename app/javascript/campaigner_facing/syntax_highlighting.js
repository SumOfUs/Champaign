// This depends on codemirror and its modes being required in
// `app/assets/javascripts/application.js`
import $ from 'jquery';

$(function() {
  $('.syntax-highlighting').each(function(idx, el) {
    const mode = $(el).data('highlight-mode') || 'htmlmixed';
    const cm = CodeMirror.fromTextArea(el, {
      mode: mode,
      theme: '3024-night',
    });
    $.subscribe('wysiwyg:submit', cm.save);
  });
});
