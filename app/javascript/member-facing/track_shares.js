import $ from 'jquery';
//TODO: Fix this import :) And rename / modify this file to hide the whatsapp button if the person is not on a mobile device
import MobileCheck from './backbone/mobile_check';

$(() => {
  if (!MobileCheck.isMobile()) {
    $('.button--whatsapp').remove();
  }

  let shared = false;

  const handleShare = (event: JQueryEventObject) => {
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

  $(window).bind('share', handleShare);
});
