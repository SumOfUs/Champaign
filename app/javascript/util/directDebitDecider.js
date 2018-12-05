// @flow

import { isObject, isMatch, find } from 'lodash';

type SupportedCountryFilter = { country: string, recurring?: boolean };
const SUPPORTED_COUNTRIES: SupportedCountryFilter[] = [
  { country: 'GB', recurring: true },
  { country: 'NL', recurring: true },
  { country: 'FR', recurring: true },
  { country: 'DE' },
  { country: 'AT' },
  { country: 'ES' },
  { country: 'AU' },
];

export function isDirectDebitSupported(data: SupportedCountryFilter) {
  return isObject(find(SUPPORTED_COUNTRIES, filter => isMatch(data, filter)));
}
