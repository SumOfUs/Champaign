// @flow
// champaign-i18n is an external (aliases to window.I18n)
// see config/webpack/app-config.js to see where it's aliased
import { translations } from 'champaign-i18n';
import type { I18nFlatDict } from 'champaign-i18n';
import { transform } from './locales/helpers';
import IntlMessageFormat from 'intl-messageformat';

const transformedMessages = {};

export default function loadTranslations(locale: string) {
  const messages = translations[locale];
  if (!messages) {
    throw new Error(`Unsuported locale: ${locale}`);
  }
  if (!transformedMessages[locale]) {
    transformedMessages[locale] = transform(messages);
  }
  return transformedMessages[locale];
}

const formatMessage = (key: string, locale: string) => {
  return new IntlMessageFormat(loadTranslations(locale)[key], locale).format(
    {}
  );
};

const isTranslationPresent = (key: string, locale: string) => {
  return !!loadTranslations(locale)[key];
};

export { formatMessage, isTranslationPresent };
