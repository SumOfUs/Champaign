import { camelCase, isPlainObject, forEach, mapKeys, mapValues } from 'lodash';

export function camelizeKeys<T>(obj: T): T {
  if (isPlainObject(obj)) {
    let aux = mapKeys(obj, (_, key: string) => camelCase(key));
    return mapValues(aux, camelizeKeys);
  } else if (Array.isArray(obj)) {
    return obj.map((val: mixed) => camelizeKeys(val));
  }
  return obj;
}
