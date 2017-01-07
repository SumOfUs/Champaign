/* @flow */
import isEmpty from 'lodash/isEmpty';
import includes from 'lodash/includes';
import type { InitialAction } from '../reducers';

export type FormField = {
  id: number;
  choices: any[];
  data_type: string; // or should this be an enum?
  default_value: ?string;
  form_id: number;
  label: string;
  name: string;
  position: number;
  required: boolean;
  created_at: string;
  updated_at: string;
};

export type FundraiserState = {
  title: string;
  currency: string;
  donationBands: {[id:string]: number[]};
  donationAmount: ?number;
  currentStep: number;
  recurring: boolean;
  recurringDefault: 'one_off' | 'recurring' | 'only_recurring';
  storeInVault: boolean;
  paymentMethods: any[];
  formId: number;
  pageId: string;
  fields: FormField[];
  form: Object;
  formValues: Object;
  currentPaymentType: ?string;
  suggestedAmount?: number;
  showDirectDebit?: boolean;
};

export type FundraiserAction =
  InitialAction
  | { type: 'change_currency', payload: string }
  | { type: 'change_amount',  payload: ?number }
  | { type: 'set_recurring', payload: boolean }
  | { type: 'set_store_in_vault', payload: boolean }
  | { type: 'set_payment_type', payload: ?string }
  | { type: 'change_step', payload: number }
  | { type: 'update_form', payload: {[key: string]: any} };

const initialState: FundraiserState = {
  amount: null,
  currency: 'USD',
  donationBands: {
    USD: [2, 5, 10, 25, 50],
    GBP: [2, 5, 10, 25, 50],
    EUR: [2, 5, 10, 25, 50],
    CAD: [2, 5, 10, 25, 50],
    AUD: [2, 5, 10, 25, 50],
    NZD: [2, 5, 10, 25, 50]
  },
  donationAmount: null,
  currentStep: 0,
  recurringDefault: 'one_off',
  recurring: false,
  storeInVault: true,
  currentPaymentType: null,
  paymentMethods: [],
  pageId: '',
  title: '',
  fields: [],
  formId: 0,
  user: {
    email: '',
    name: '',
    country: '',
    postal: '',
  },
  form: {},
  formValues: {},
};

// `supportedCurrency` gets a currency string and compares it against our list of supported currencies.
// If our currency is not in the list of supported currencies, it will return the default currency (which,
// by default, is the first currency in our supoortedCurrencies list)
function supportedCurrency(currency: string, supportedCurrencies: string[]): string {
  const list = isEmpty(supportedCurrencies) ? Object.keys(initialState.donationBands) : supportedCurrencies;
  const value = currency.toUpperCase();

  if (includes(list, value)) {
    return value;
  } else {
    return list[0];
  }
}

export default function fundraiserReducer(state: FundraiserState = initialState, action: FundraiserAction): FundraiserState {
  switch (action.type) {
    case 'parse_champaign_data':
      const {
        currency,
        donationBands,
        recurringDefault,
      } = action.payload.fundraiser;

      return {
        ...state,
        ...action.payload.fundraiser,
        currency: supportedCurrency(currency, Object.keys(donationBands)),
        donationBands: isEmpty(donationBands) ? state.donationBands : donationBands,
        recurring: (recurringDefault === 'recurring') || (recurringDefault === 'only_recurring'),
      };
    case 'reset_member':
      return {
        ...state,
        outstandingFields: state.fields.map(field => field.name),
        formValues: {},
      };
    case 'change_currency':
      return { ...state, currency: supportedCurrency(action.payload, Object.keys(state.donationBands)) };
    case 'change_amount':
      return { ...state, donationAmount: action.payload || null };
    case 'change_step':
      return { ...state, currentStep: action.payload };
    case 'proceed_step':
      const nextStep = state.currentStep + 1;
      return { ...state, currentStep: nextStep };
    case 'update_form':
      return { ...state, form: action.payload };
    case 'set_store_in_vault':
      return { ...state, storeInVault: action.payload };
    case 'set_payment_type':
      return { ...state, currentPaymentType: action.payload };
    case 'set_recurring':
      return { ...state, recurring: action.payload };
    default:
      return state;
  }
}
