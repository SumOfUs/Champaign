import { formatMessage } from '../util/TranslationsLoader';

const initializeCookieConsent = () => {
  $(() => {
    if (isEEA()) {
      const locale = window.champaign.page.language_code || 'en';
      window.cookieconsent.initialise({
        theme: 'block',
        content: {
          message: formatMessage('cookie_consent.message', locale),
          dismiss: formatMessage('cookie_consent.dismiss_button_text', locale),
          link: formatMessage('cookie_consent.more_info_link_text', locale),
          href: 'http://cookiesandyou.com',
        },
        layouts: {
          basic: '{{messagelink}}{{compliance}}',
        },
      });
    }
  });
};

const isEEA = () => {
  let countryCode = window.champaign.personalization.location.country;
  let countries = window.champaign.countries;
  const country = countries.find(c => c.alpha2 === countryCode);
  if (!country) return false;
  return country.eea_member;
};

export default initializeCookieConsent;
