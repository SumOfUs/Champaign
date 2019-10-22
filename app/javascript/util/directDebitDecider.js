import { isObject, isMatch, find } from 'lodash';

const SUPPORTED_COUNTRIES = [
  { country: 'GB' },
  { country: 'NL' },
  { country: 'FR' },
  { country: 'DE' },
  { country: 'AT' },
  { country: 'ES' },
  { country: 'AU' },
  { country: 'BE' },
  { country: 'CY' },
  { country: 'EE' },
  { country: 'IE' },
  { country: 'IT' },
  { country: 'LV' },
  { country: 'LU' },
  { country: 'MC' },
  { country: 'PT' },
  { country: 'SM' },
  { country: 'SI' },
];

// countries not added in the list
// as Gocardless mention the countries
// have huge payment failure rate

// { country: 'FI' },
// { country: 'GR' },
// { country: 'LT' },
// { country: 'SK' }

export function isDirectDebitSupported(data) {
  return isObject(find(SUPPORTED_COUNTRIES, filter => isMatch(data, filter)));
}
