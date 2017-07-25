// @flow
// champaign-i18n is an external (aliases to window.I18n)
// see config/webpack/app-config.js to see where it's aliased
import { translations } from 'champaign-i18n';
import type { I18nFlatDict } from 'champaign-i18n';
import { transform } from './locales/helpers';

export default function loadTranslations(locale: string) {
  const messages = translations[locale];
  if (!messages) {
    throw new Error(`Unsuported locale: ${locale}`);
  }
  return transform(messages);
}
