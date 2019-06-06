// @flow
import $ from 'jquery';
import ee from '../../shared/pub_sub';

$(function() {
  const fixPreviewElement = function() {
    /*
     *
     * NOTE
     * This function is currently not invoked.
     * The plan is to have the preview div fix itself to view
     * so it remains visible as the user scrolls down the page.
     *
     */

    const $preview = $('.plugin-form-preview');

    let originalPosition = $preview.offset(),
      originalTop = originalPosition.top;

    const handleSroll = function() {
      const css = { position: 'fixed', top: '0px' };
      if ($(window).scrollTop() >= originalTop) {
        $preview.css(css);
      } else {
        $preview.css({ position: 'static' });
      }
    };

    $(window).scroll(handleSroll);
  };

  const updatePreview = function() {
    const updater = function(plugin_type) {
      return function(ii, el) {
        const $el = $(el);
        const plugin_id = $el.data('plugin-id');
        const url = ['/plugins/forms/', plugin_type, '/', plugin_id].join('');

        $.get(url, function(resp) {
          $el.find('.plugin-form-preview .content').html(resp);
        });
      };
    };
    $('.plugin.petition').each(updater('petition'));
    $('.plugin.fundraiser').each(updater('fundraiser'));
    $('.plugin.survey').each(updater('survey'));
  };

  if ($('.plugin-form-preview .content').length > 0) {
    ee.on('plugin:form:preview:update', updatePreview);
    ee.on('page:saved', updatePreview);
  }

  $('.plugin.petition, .plugin.fundraiser, .plugin.survey').on(
    'ajax:success',
    function() {
      ee.emit('plugin:form:preview:update');
    }
  );

  $('.plugin.petition, .plugin.fundraiser, .plugin.survey').on(
    'ajax:error',
    function(e, xhr, resp) {
      //for debugging
      console.log(xhr, resp);
    }
  );
});

const bindCaretToggle = function() {
  $('[data-toggle="collapse"]').on('click', function(e) {
    $(this).toggleClass('open');
  });
};

ee.on('plugin:form:loaded', bindCaretToggle);
