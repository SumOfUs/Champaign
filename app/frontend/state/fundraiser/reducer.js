/* @flow */
import isEmpty from 'lodash/isEmpty';
import includes from 'lodash/includes';
import type { FundraiserAction } from './actions';

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

export type DonationBands = {[id: string]: number[]};
export type FeaturedAmounts = {[id: string]: number};

export type Fundraiser = {
  title: string;
  currency: string;
  donationBands: DonationBands;
  donationFeaturedAmount?: number;
  donationAmount?: number;
  currentStep: number;
  recurring: boolean;
  recurringDefault: 'one_off' | 'recurring' | 'only_recurring';
  storeInVault: boolean;
  paymentMethods: any[];
  formId: string;
  fields: FormField[];
  form: Object;
  formValues: Object;
  currentPaymentType: ?string;
  suggestedAmount?: number;
  showDirectDebit?: boolean;
  freestanding?: boolean;
  submitting: boolean;
  preselectAmount: boolean;
  outstandingFields: string[];
};

const initialState: Fundraiser = {
  currency: 'USD',
  donationBands: {
    USD: [2, 5, 10, 25, 50],
    GBP: [2, 5, 10, 25, 50],
    EUR: [2, 5, 10, 25, 50],
    CAD: [2, 5, 10, 25, 50],
    AUD: [2, 5, 10, 25, 50],
    NZD: [2, 5, 10, 25, 50]
  },
  donationAmount: undefined,
  currentStep: 0,
  recurringDefault: 'one_off',
  recurring: false,
  storeInVault: true,
  currentPaymentType: null,
  showDirectDebit: false,
  paymentMethods: [],
  title: '',
  fields: [],
  formId: "",
  form: {},
  formValues: {},
  submitting: false,
  freestanding: false,
  outstandingFields: [],
  preselectAmount: false,
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

export function pickMedianAmount(bands: DonationBands, currency: string): number {
  const amounts = bands[currency];
  return amounts[Math.floor(amounts.length / 2)] || 0;
}

export default function fundraiserReducer(state: Fundraiser = initialState, action: FundraiserAction): Fundraiser {
  switch (action.type) {
    case 'parse_champaign_data':
      const { fundraiser } = action.payload;
      const {
        currency,
        donationBands,
        recurringDefault,
      } = fundraiser;
      const amounts = isEmpty(donationBands) ? state.donationBands : donationBands;

      return Object.assign({}, state, fundraiser, {
        currency: supportedCurrency(currency, Object.keys(donationBands)),
        donationBands: amounts,
        donationFeaturedAmount: fundraiser.preselectAmount ? pickMedianAmount(amounts, currency) : undefined,
        recurring: (recurringDefault === 'recurring') || (recurringDefault === 'only_recurring'),
      });
    case 'reset_member':
      return Object.assign({}, state, {
        outstandingFields: state.fields.map(field => field.name),
        formValues: {},
      });
    case 'set_submitting':
      return Object.assign({}, state, {
        submitting: action.payload
      });
    case 'change_currency':
      return Object.assign({}, state, {
        currency: supportedCurrency(action.payload, Object.keys(state.donationBands)),
        donationFeaturedAmount: state.preselectAmount ? pickMedianAmount(state.donationBands, action.payload): undefined,
      });
    case 'change_amount':
      return Object.assign({}, state, {
        donationAmount: action.payload || undefined
      });
    case 'change_step':
      return Object.assign({}, state, {
        currentStep: action.payload
      });
    case 'proceed_step':
      const nextStep = state.currentStep + 1;
      return Object.assign({}, state, {
        currentStep: nextStep
      });
    case 'update_form':
      return Object.assign({}, state, {
        form: action.payload
      });
    case 'set_store_in_vault':
      return Object.assign({}, state, {
        storeInVault: action.payload
      });
    case 'set_payment_type':
      return Object.assign({}, state, {
        currentPaymentType: action.payload
      });
    case 'set_recurring':
      return Object.assign({}, state, {
        recurring: action.payload
      });
    default:
      return state;
  }
}
