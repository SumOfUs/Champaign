// @flow

const translations = {
  ...require('../../../config/locales/member_facing.de.yml'),
  ...require('../../../config/locales/member_facing.en.yml'),
  ...require('../../../config/locales/member_facing.fr.yml'),
};

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
  Object.keys(translations).forEach((key) => {
    const val = translations[key];
    const fullKey = (prefix === '') ? key : `${prefix}.${key}`;
    if(typeof(val) === 'string'){
      flatTranslations[fullKey] = val;
    } else {
      Object.assign(
        flatTranslations,
        flattenTranslations(translations[key], fullKey)
      );
    }
  });
  return flatTranslations;
}
