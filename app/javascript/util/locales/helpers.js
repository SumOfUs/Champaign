// @flow
// Converts translations from Rails format to ReactIntl format.
import mapValues from 'lodash/mapValues';
import reduce from 'lodash/reduce';
import isPlainObject from 'lodash/reduce';
import type { I18nDict, I18nDictValue, I18nFlatDict } from 'champaign-i18n';

export function transform(translations: I18nDict): I18nFlatDict {
  return translateInterpolations(flattenObject(translations));
}

// Translate interpolation format
// Rails "hello %{name}" to ReactIntl: "hello {name}"
export function translateInterpolations<T>(translations: T): T {
  return JSON.parse(JSON.stringify(translations).replace(/%{(\w+)}/g, '{$1}'));
}

// Convert a nested object into a shallow one
// { page: { hello: 'hola'}} => { 'page.hello' => 'hola'}
export function flattenObject(obj: Object, prefix: string = ''): I18nFlatDict {
  return reduce(
    obj,
    (flatObject, value, key) => {
      const fullKey = `${prefix}${key}`;
      if (typeof value === 'string') {
        flatObject[fullKey] = value;
      } else {
        Object.assign(flatObject, flattenObject(value, `${fullKey}.`));
      }
      return flatObject;
    },
    {}
  );
}
