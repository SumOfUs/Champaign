import { camelCase, isPlainObject, forEach, mapKeys, mapValues } from 'lodash';

export function camelizeKeys<T>(obj: T): T {
  if (isPlainObject(obj)) {
    return mapValues(mapKeys(obj, camelCase), camelizeKeys);
  } else if (Array.isArray(obj)) {
    return obj.map((val: mixed) => camelizeKeys(val));
  }
  return obj;
}
