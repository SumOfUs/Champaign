import EEA_LIST from '../../shared/eea-list';

export default {
  show() {
    const cookieconsent = window['cookieconsent'];
    const I18n = window['I18n'];
    cookieconsent.initialise({
      theme: 'edgeless',
      position: 'top',
      content: {
        message: I18n.t('cookie_consent.message'),
        dismiss: I18n.t('cookie_consent.dismiss_button_text'),
        link: I18n.t('cookie_consent.privacy_policy_link_text'),
        href: I18n.lookup('cookie_consent.privacy_policy_url') || '/privacy',
      },
    });
  },

  init(countryCode: string) {
    if (EEA_LIST.includes(countryCode)) {
      import('cookieconsent').then(() => this.show());
    }
  },
};
