/* @flow */
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
  currencies: string[];
  donationBands: number[];
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
  currentPaymentType: ?string;
  suggestedAmount?: number;
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
  currencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'NZD'],
  donationBands: [1, 2, 5, 10, 25],
  donationAmount: null,
  currentStep: 0,
  recurringDefault: 'one_off',
  recurring: false,
  storeInVault: false,
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
};

export default function fundraiserReducer(state: FundraiserState = initialState, action: FundraiserAction): FundraiserState {
  switch (action.type) {
    case 'parse_champaign_data':
      return {
        ...initialState,
        ...action.payload.fundraiser,
        recurring: (action.payload.fundraiser.recurringDefault === 'only_recurring'),
        donationBands: initialState.donationBands
      };
    case 'reset_member':
      return { ...state, outstandingFields: state.fields.map(field => field.name) };
    case 'change_currency':
      return { ...state, currency: action.payload };
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
