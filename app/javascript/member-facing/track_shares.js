import $ from 'jquery';
import MobileCheck from './backbone/mobile_check';

$(() => {
  if (!MobileCheck.isMobile()) {
    $('.button--whatsapp').remove();
  }

  let shared = false;

  $('.button--whatsapp').click(function(e) {
    e.preventDefault();
    $.post({
      url: window.location.origin + '/api/shares/track',
      data: {
        variant_type: 'whatsapp',
        variant_id: $(this).attr('variant_id'),
      },
    })
      .done(function() {
        console.log('So that happened...');
      })
      .fail(function(error) {
        console.log('Swimming with the fishes.', error);
      })
      .always(function() {
        console.log('Always redirect to the share page regardless.');
      });
  });

  const handleFacebookShare = event => {
    // SP triggers 'share' twice so need to block
    // a duplicate event from being posted to GA.
    if (shared) return;

    const share = event.originalEvent.share;
    shared = true;

    if (share.share_type === 'f') {
      ga(
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
