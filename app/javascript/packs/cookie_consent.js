// @flow
import 'cookieconsent';
import $ from 'jquery';
import {
  formatMessage,
  isTranslationPresent,
} from '../util/TranslationsLoader';

$(() => {
  if (isEEA()) {
    const locale = window.champaign.page.language_code || 'en';
    let privacyPolicyURL;
    if (isTranslationPresent('cookie_consent.privacy_policy_url', locale)) {
      privacyPolicyURL = formatMessage(
        'cookie_consent.privacy_policy_url',
        locale
      );
    } else {
      privacyPolicyURL = '/privacy';
    }

    window.cookieconsent.initialise({
      theme: 'edgeless',
      position: 'top',
      content: {
        message: formatMessage('cookie_consent.message', locale),
        dismiss: formatMessage('cookie_consent.dismiss_button_text', locale),
        link: formatMessage('cookie_consent.privacy_policy_link_text', locale),
        href: privacyPolicyURL,
      },
    });
  }
});

const isEEA = () => {
  let countryCode = window.champaign.personalization.location.country;
  let countries = window.champaign.countries;
  const country = countries.find(c => c.alpha2 === countryCode);
  if (!country) return false;
  return country.eea_member;
};
