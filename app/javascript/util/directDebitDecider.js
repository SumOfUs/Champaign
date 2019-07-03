import { isObject, isMatch, find } from 'lodash';

const SUPPORTED_COUNTRIES = [
  { country: 'GB', recurring: true },
  { country: 'NL', recurring: true },
  { country: 'FR', recurring: true },
  { country: 'DE' },
  { country: 'AT' },
  { country: 'ES' },
  { country: 'AU' },
];

export function isDirectDebitSupported(data) {
  return isObject(find(SUPPORTED_COUNTRIES, filter => isMatch(data, filter)));
}
