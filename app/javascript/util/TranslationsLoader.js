// champaign-i18n is an external (aliases to window.I18n)
// see config/webpack/custom.js to see where it's aliased
import flatten from 'flat';
import I18n from 'champaign-i18n';
import { mapValues } from 'lodash';
import { replaceInterpolations } from './locales/helpers';

const translations = mapValues(I18n.translations, tree =>
  mapValues(flatten(tree), replaceInterpolations)
);

export default function loadTranslations(locale) {
  if (!translations[locale]) {
    throw new Error(`Unsuported locale: ${locale}`);
  }
  return translations[locale];
}
