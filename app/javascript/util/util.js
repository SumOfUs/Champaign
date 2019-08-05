import { camelCase, mapKeys, mapValues } from 'lodash';

export function camelizeKeys(obj) {
  if (!obj) return obj;
  if (Array.isArray(obj)) return obj.map(v => camelizeKeys(v));
  if (typeof obj === 'object') {
    const camelCased = mapKeys(obj, (v, k) => camelCase(k));
    return mapValues(camelCased, v => camelizeKeys(v));
  }
  return obj;
}
