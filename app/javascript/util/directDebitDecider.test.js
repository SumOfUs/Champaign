import { isDirectDebitSupported } from './directDebitDecider';

describe('isDirectDebitSupported', () => {
  test('Germany always supports Direct Debit', () => {
    expect(isDirectDebitSupported({ country: 'DE', recurring: false })).toEqual(
      true
    );
    expect(isDirectDebitSupported({ country: 'DE', recurring: true })).toEqual(
      true
    );
  });

  test('Austria always supports Direct Debit', () => {
    expect(isDirectDebitSupported({ country: 'AT', recurring: false })).toEqual(
      true
    );
    expect(isDirectDebitSupported({ country: 'AT', recurring: true })).toEqual(
      true
    );
  });

  test('Australia always supports Direct Debit', () => {
    expect(isDirectDebitSupported({ country: 'AU', recurring: false })).toEqual(
      true
    );
    expect(isDirectDebitSupported({ country: 'AU', recurring: true })).toEqual(
      true
    );
  });

  test('Spain always supports Direct Debit', () => {
    expect(isDirectDebitSupported({ country: 'ES', recurring: false })).toEqual(
      true
    );
    expect(isDirectDebitSupported({ country: 'ES', recurring: true })).toEqual(
      true
    );
  });

  test('Great Britain only supports Direct Debit for recurring payments', () => {
    expect(isDirectDebitSupported({ country: 'GB', recurring: false })).toEqual(
      false
    );
    expect(isDirectDebitSupported({ country: 'GB', recurring: true })).toEqual(
      true
    );
  });

  test('The Netherlands only supports Direct Debit for recurring payments', () => {
    expect(isDirectDebitSupported({ country: 'NL', recurring: false })).toEqual(
      false
    );
    expect(isDirectDebitSupported({ country: 'NL', recurring: true })).toEqual(
      true
    );
  });

  test('France only supports Direct Debit for recurring payments', () => {
    expect(isDirectDebitSupported({ country: 'FR', recurring: false })).toEqual(
      false
    );
    expect(isDirectDebitSupported({ country: 'FR', recurring: true })).toEqual(
      true
    );
  });
});
