import * as $ from 'jquery';

const version = 1;

const showNotice = () => {
  const banner = $('.cc-banner');
  const headerLogo = $('.header-logo');

  headerLogo.fadeOut(() => banner.fadeIn('slow'));

  banner.find('.cc-btn').on('click', () => {
    banner.hide();
    headerLogo.show();
  });
};

export const DoubleOptIn = {
  handleActionSuccess(resp) {
    if (!resp || !resp.double_opt_in) {
      return;
    }

    showNotice();
  },
};

$(() => {
  if (window.location.search.match(/double_opt_in=true/)) {
    showNotice();
  }
});
