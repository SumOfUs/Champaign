/* @flow */
import { includes, isEmpty, keys, pick, reduce, without } from 'lodash';

import type {
  Fundraiser as State,
  FundraiserAction as Action,
  EnumRecurringDefault,
  FeaturedAmountState,
  PaymentType,
  RecurringState,
  DonationBands,
} from './types';

export const initialState: State = {
  currency: 'USD',
  disableSavedPayments: false,
  donationBands: {
    USD: [2, 5, 10, 25, 50],
    GBP: [2, 5, 10, 25, 50],
    EUR: [2, 5, 10, 25, 50],
    CHF: [2, 5, 10, 25, 50],
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

export default (state: State = initialState, action: Action): State => {
  switch (action.type) {
    case 'initialize_fundraiser':
      const initialData = pick(
        action.payload,
        'member',
        'pageId',
        'formValues',
        'formId',
        'outstandingFields',
        'title',
        'fields',
        'freestanding',
        'donationAmount'
      );
      initialData.formValues = initialData.formValues || {};
      return { ...state, ...initialData };
    case 'search_string_overrides':
      return searchStringOverrides(state, action.payload);
    case 'login_member':
      const formValues = action.payload.formValues || {};
      const outstandingFields = state.fields
        .map(field => field.name)
        .filter(fieldName => !keys(formValues).includes(fieldName));

      return {
        ...state,
        form: formValues,
        formValues,
        outstandingFields,
      };
    case 'reset_member':
      return {
        ...state,
        outstandingFields: state.fields.map(field => field.name),
        formValues: {},
      };
    case 'change_currency': {
      const { preselectAmount, donationBands } = state;
      const currency = supportedCurrency(action.payload, keys(donationBands));
      return {
        ...state,
        ...featuredAmountState(preselectAmount, { donationBands, currency }),
        currency,
      };
    }
    case 'change_amount':
      const donationAmount = action.payload || undefined;
      return { ...state, donationAmount };
    case 'change_step':
      return { ...state, currentStep: action.payload };
    case 'proceed_step':
      const currentStep = state.currentStep + 1;
      return { ...state, currentStep };
    case 'update_form':
      return { ...state, form: action.payload };
    case 'set_direct_debit_only':
      if (state.showDirectDebit) {
        return {
          ...state,
          currentPaymentType: 'gocardless',
          directDebitOnly: action.payload,
        };
      }
      return state;
    case 'set_donation_bands':
      const payload: DonationBands = action.payload;
      const donationBands: DonationBands = isEmpty(payload)
        ? state.donationBands
        : payload;
      const currency = supportedCurrency(state.currency, keys(donationBands));
      const preselectAmount = state.preselectAmount;
      return {
        ...state,
        ...featuredAmountState(preselectAmount, { donationBands, currency }),
        currency,
        donationBands,
      };
    case 'set_payment_type':
      return { ...state, currentPaymentType: action.payload };
    case 'set_recurring':
      return { ...state, recurring: action.payload };
    case 'set_recurring_defaults':
      return { ...state, ...recurringState(action.payload) };
    case 'set_store_in_vault':
      return { ...state, storeInVault: action.payload };
    case 'set_submitting':
      return { ...state, submitting: action.payload };
    case 'toggle_direct_debit':
      return { ...state, showDirectDebit: action.payload };
    case 'preselect_amount':
      return {
        ...state,
        ...featuredAmountState(action.payload, {
          donationBands: state.donationBands,
          currency: state.currency,
        }),
      };
    default:
      return state;
  }
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

const searchStringHandlers = {
  hide_spm: function hideSavedPayments(state: State, value: string): State {
    if (value === '1') return { ...state, disableSavedPayments: true };
    else return state;
  },
};

// Overrides state values based on url query/search string (highest priority)
type Search = { [key: string]: string };
export function searchStringOverrides(state: State, search: Search): State {
  const handlers = pick(searchStringHandlers, keys(search));
  return reduce(handlers, (res, handler, k) => handler(res, search[k]), state);
}
