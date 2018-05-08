// @flow
import $ from 'jquery';
import MobileCheck from './backbone/mobile_check';

$(() => {
  if (!MobileCheck.isMobile()) {
    $('.button--whatsapp').remove();
  }

  $('.button--whatsapp').click(function(e) {
    e.preventDefault();
    $.post({
      url: window.location.origin + '/api/shares/track',
      data: {
        variant_type: 'whatsapp',
        variant_id: $(this).attr('variant_id'),
      },
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

    if (share.share_type === 'f' && window.ga) {
      window.ga(
        'send',
        'event',
        'fb:sign_share',
        'share_progress_share',
        window.champaign.personalization.urlParams.id
      );
    }
  };

  $(window).bind('share', handleFacebookShare);
});
