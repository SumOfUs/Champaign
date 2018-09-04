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
  version(versionNumber?: number) {
    if (versionNumber) {
      version = versionNumber;
      $('.action-form').append(
        `<input type='hidden' name='test_version' value='${version}' />`
      );
    }
    return version;
  },

  handleActionSuccess(resp: Response) {
    if (!resp || !resp.double_opt_in) return;

    if (DoubleOptIn.version() === 2) {
      showNotice();
    } else {
      window.location.href = resp.follow_up;
    }
  },
};

$(() =>
  $('.action-form').on('ajax:success', (e, data) =>
    DoubleOptIn.handleActionSuccess(data)
  )
);

export default DoubleOptIn;
