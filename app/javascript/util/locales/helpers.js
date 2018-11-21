// @flow
// Converts translations from Rails format to ReactIntl format.
import flatten from 'flat';
import type { FlatObject } from 'flat';
import mapValues from 'lodash/mapValues';
import reduce from 'lodash/reduce';
import isPlainObject from 'lodash/reduce';

export function transform(translations: Object): FlatObject {
  return mapValues(flatten(translations), replaceInterpolations);
}

export function replaceInterpolations<T>(value: T): T {
  if (typeof value === 'string') return value.replace(/%{(\w+)}/g, '{$1}');
  return value;
}
