// @flow
import 'cookieconsent';
import $ from 'jquery';
import I18n from 'champaign-i18n';

$(() => {
  if (isEEA()) {
    window.cookieconsent.initialise({
      theme: 'edgeless',
      position: 'top',
      content: {
        message: I18n.t('cookie_consent.message'),
        dismiss: I18n.t('cookie_consent.dismiss_button_text'),
        link: I18n.t('cookie_consent.privacy_policy_link_text'),
        href: I18n.lookup('cookie_consent.privacy_policy_url') || '/privacy',
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
