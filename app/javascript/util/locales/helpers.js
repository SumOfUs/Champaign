// Converts translations from Rails format to ReactIntl format.
import mapValues from 'lodash/mapValues';

export function sanitizeTranslations(translations) {
  return mapValues(translations, value => translateInterpolationFormat(flattenTranslations(value)));
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
