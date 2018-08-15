// @flow
import $ from 'jquery';

let version = 1;

const DoubleOptIn = {
  version(versionNumber: number) {
    if (versionNumber) {
      version = versionNumber;
      $('.action-form').append(
        `<input type='hidden' name='test_version' value='${version}' />`
      );
    }
    return version;
  },

  showNotice() {
    const banner = $('.cc-banner');
    const headerLogo = $('.header-logo');

    headerLogo.fadeOut(() => banner.fadeIn('slow'));

    banner.find('.cc-btn').on('click', () => {
      banner.hide();
      headerLogo.show();
    });
  },
};

export default DoubleOptIn;
