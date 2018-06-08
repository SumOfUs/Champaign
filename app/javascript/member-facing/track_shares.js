import $ from 'jquery';
import MobileCheck from './backbone/mobile_check';

$(() => {
  if (!MobileCheck.isMobile()) {
    $('.button--whatsapp').remove();
  }

  let shared = false;

  const handleShare = event => {
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

  $(window).bind('share', handleShare);
});
