// @flow
import { keys, pick, reduce } from 'lodash';
import type {
  DonationBands,
  EnumRecurringDefault,
  FeaturedAmountState,
  Fundraiser,
  PaymentType,
  RecurringState,
} from './types';

export const initialState: Fundraiser = {
  currency: 'USD',
  disableSavedPayments: false,
  donationBands: {
    USD: [2, 5, 10, 25, 50],
    GBP: [2, 5, 10, 25, 50],
    EUR: [2, 5, 10, 25, 50],
    CAD: [2, 5, 10, 25, 50],
    AUD: [2, 5, 10, 25, 50],
    NZD: [2, 5, 10, 25, 50],
  },
  donationAmount: undefined,
  currentStep: 0,
  recurringDefault: 'one_off',
  recurring: false,
  storeInVault: true,
  currentPaymentType: 'card',
  showDirectDebit: false,
  directDebitOnly: false,
  paymentMethods: [],
  title: '',
  fields: [],
  formId: '',
  form: {},
  formValues: {},
  submitting: false,
  freestanding: false,
  outstandingFields: [],
  preselectAmount: false,
};

export const RECURRING_DEFAULTS: EnumRecurringDefault[] = [
  'one_off',
  'recurring',
  'only_recurring',
];

// `supportedCurrency` gets a currency string and compares it against our list of supported currencies.
// If our currency is not in the list of supported currencies, it will return the default currency (which,
// by default, is the first currency in our supoortedCurrencies list)
export function supportedCurrency(
  currency?: string,
  currencies: string[] = Object.keys(initialState.donationBands)
): string {
  return currencies.find(c => c === currency) || currencies[0];
}

export function recurringState(recurringValue: string = ''): RecurringState {
  const recurringDefault: EnumRecurringDefault =
    RECURRING_DEFAULTS.find(i => i === recurringValue.toLowerCase()) ||
    'one_off';
  return {
    recurring: recurringDefault !== 'one_off',
    recurringDefault,
  };
}

export function pickMedianAmount(
  bands: DonationBands,
  currency: string
): number {
  const amounts = bands[currency];
  return amounts[Math.floor(amounts.length / 2)] || 0;
}

export function featuredAmountState(
  preselectAmount: boolean,
  state?: { donationBands: DonationBands, currency: string }
): FeaturedAmountState {
  if (preselectAmount && state) {
    return {
      preselectAmount,
      donationFeaturedAmount: pickMedianAmount(
        state.donationBands,
        state.currency
      ),
    };
  }

  return {
    preselectAmount,
  };
}

function hideSavedPayments(state: Fundraiser, value: string): Fundraiser {
  if (value === '1') return { ...state, disableSavedPayments: true };
  else return state;
}

const searchStringHandlers = {
  hide_spm: hideSavedPayments,
};

// Overrides state values based on url query/search string (highest priority)
export function searchStringOverrides(
  state: Fundraiser,
  search: { [key: string]: string }
): Fundraiser {
  const handlers = pick(searchStringHandlers, keys(search));
  return reduce(handlers, (res, handler, k) => handler(res, search[k]), state);
}
