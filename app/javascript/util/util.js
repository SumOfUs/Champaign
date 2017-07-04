// @flow
import { camelCase, mapKeys, mapValues } from 'lodash';

export function camelizeKeys<T>(obj: T): Object | T {
  if (Array.isArray(obj)) return obj.map(v => camelizeKeys(v));
  if (typeof obj === 'object') {
    const camelCased = mapKeys(obj, (v, k: string): string => camelCase(k));
    return mapValues(camelCased, (v: Object) => camelizeKeys(v));
  }
  return obj;
}
