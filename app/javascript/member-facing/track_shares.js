// @flow
import $ from 'jquery';
import MobileCheck from './backbone/mobile_check';
import { logEvent } from './../util/log_event';

$(() => {
  if (!MobileCheck.isMobile()) {
    $('.button--whatsapp').remove();
  }

  $('.button--whatsapp').click(function(e) {
    e.preventDefault();
    $.post(window.location.origin + '/api/shares/track', {
      variant_type: 'whatsapp',
      variant_id: $(this).attr('variant_id'),
    }).then(function() {
      window.location = $(e.currentTarget)
        .children('a')
        .attr('href');
    });
  });

  let shared = false;

  const handleFacebookShare = (event: JQueryEventObject) => {
    // SP triggers 'share' twice so need to block
    // a duplicate event from being posted to GA.
    if (shared) return;

    // $FlowIgnore
    const share = event.originalEvent.share;
    shared = true;

    logEvent('social_share', share);
  };

  $(window).bind('share', handleFacebookShare);
});
