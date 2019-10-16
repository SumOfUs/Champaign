import { isDirectDebitSupported } from './directDebitDecider';

const SUPPORTED_COUNTRIES = [
  { code: 'GB', name: 'United Kingdom' },
  { code: 'NL', name: 'Netherland' },
  { code: 'FR', name: 'France' },
  { code: 'DE', name: 'Germany' },
  { code: 'AT', name: 'Austria' },
  { code: 'ES', name: 'Spain' },
  { code: 'AU', name: 'Australia' },
  { code: 'BE', name: 'Belgiuim' },
  { code: 'CY', name: 'Cyprus' },
  { code: 'EE', name: 'Estonia' },
  { code: 'IE', name: 'Ireland' },
  { code: 'IT', name: 'Italy' },
  { code: 'LV', name: 'Latvia' },
  { code: 'LU', name: 'Luxembourg' },
  { code: 'MC', name: 'Monaco' },
  { code: 'PT', name: 'Portugal' },
  { code: 'SM', name: 'San Marino' },
  { code: 'SI', name: 'Slovenia' },
  { code: 'CA', name: 'Canada' },
  { code: 'US', name: 'United States' },
];

describe('isDirectDebitSupported', () => {
  SUPPORTED_COUNTRIES.forEach(function(c) {
    test(c.name + ' always supports Direct Debit', () => {
      expect(
        isDirectDebitSupported({ country: c.code, recurring: false })
      ).toEqual(true);
      expect(
        isDirectDebitSupported({ country: c.code, recurring: true })
      ).toEqual(true);
    });
  });
});
