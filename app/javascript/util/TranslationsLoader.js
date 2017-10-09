// @flow
// champaign-i18n is an external (aliases to window.I18n)
// see config/webpack/app-config.js to see where it's aliased
import { translations } from 'champaign-i18n';
import type { I18nFlatDict } from 'champaign-i18n';
import { transform } from './locales/helpers';

export default function loadTranslations(locale: string) {
  const lang = locale.split('-')[0];
  const messages = translations[lang];
  if (!messages) {
    throw new Error(`Unsupported locale: ${lang}`);
  }
  return transform(messages);
}
