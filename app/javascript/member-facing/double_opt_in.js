// @flow
import $ from 'jquery';

type Response = {
  double_opt_in: boolean,
  follow_up: string,
};

let version = 1;

const showNotice = () => {
  const banner = $('.cc-banner');
  const headerLogo = $('.header-logo');

  headerLogo.fadeOut(() => banner.fadeIn('slow'));

  banner.find('.cc-btn').on('click', () => {
    banner.hide();
    headerLogo.show();
  });
};

const DoubleOptIn = {
  handleActionSuccess(resp: Response) {
    if (!resp || !resp.double_opt_in) return;

    showNotice();
  },
};

$(() => {
  if (window.location.search.match(/double_opt_in=true/)) {
    showNotice();
  }
});

export default DoubleOptIn;
