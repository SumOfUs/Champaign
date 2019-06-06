// @flow
// This depends on codemirror and its modes being required in
// `app/assets/javascripts/application.js`
import $ from 'jquery';
import Backbone from 'backbone';
import ee from '../../shared/pub_sub';

$(function() {
  $('.syntax-highlighting').each(function(idx, el) {
    const mode = $(el).data('highlight-mode') || 'htmlmixed';
    // $FlowIgnore
    const cm = CodeMirror.fromTextArea(el, {
      mode: mode,
      theme: '3024-night',
    });
    ee.on('wysiwyg:submit', cm.save);
  });
});
