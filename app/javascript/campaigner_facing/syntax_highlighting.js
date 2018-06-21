// This depends on codemirror and its modes being required in
// `app/assets/javascripts/application.js`
import ee from '../shared/pub_sub';

$(function() {
  $('.syntax-highlighting').each(function(idx, el) {
    const mode = $(el).data('highlight-mode') || 'htmlmixed';
    const cm = CodeMirror.fromTextArea(el, {
      mode: mode,
      theme: '3024-night',
    });
    ee.on('wysiwyg:submit', cm.save);
  });
});
