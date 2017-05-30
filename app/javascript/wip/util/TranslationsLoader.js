// @flow weak
import translations from '../locales/translations';

export default function loadTranslations(locale: string) {
  if (!translations[locale]) {
    throw new Error(`Unsuported locale: ${locale}`);
  }
  return translations[locale];
}
