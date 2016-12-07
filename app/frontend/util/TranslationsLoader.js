// @flow
import _ from 'lodash';
const supportedLocales = ['en', 'fr', 'de'];
const translations = {};

for (const locale of supportedLocales) {
  translations[locale] = require(`../../../config/locales/member_facing.${locale}.yml`)[locale];
}

export default function loadTranslations(locale: string) {
  if(translations[locale] === undefined) {
    throw new Error(`Unsuported locale ${locale}`);
  }

  return sanitizeTranslations(translations[locale]);
}

// Converts translations from Rails format to ReactIntl format.
function sanitizeTranslations(translations) {
  return translateInterpolationFormat(flattenTranslations(translations));
}

// Translate interpolation format
// Rails "hello %{name}" to ReactIntl: "hello {name}"
function translateInterpolationFormat(translations) {
  const str = JSON.stringify(translations).replace(/%{(\w+)}/g, '{$1}');
  return JSON.parse(str);
}

// Convert a nested translations object into a shallow one
// { page: { hello: 'hola'}} => { 'page.hello' => 'hola'}
function flattenTranslations(translations, prefix = '') {
  const flatTranslations = {};
  _.each(translations, (val, key) => {
    const fullKey = (prefix === '') ? key : `${prefix}.${key}`;
    if(typeof(val) === 'string'){
      flatTranslations[fullKey] = val;
    } else {
      _.assign(
        flatTranslations,
        flattenTranslations(translations[key], fullKey)
      );
    }
  });
  return flatTranslations;
}

