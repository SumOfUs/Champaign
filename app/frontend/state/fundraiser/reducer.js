/* @flow */
import type { InitialAction } from '../reducers';
import _ from 'lodash';

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
  showExpressDonations?: boolean;
};

export type FundraiserAction =
  InitialAction
  | { type: 'change_currency', payload: string }
  | { type: 'change_amount',  payload: ?number }
  | { type: 'set_recurring', payload: boolean }
  | { type: 'set_store_in_vault', payload: boolean }
  | { type: 'set_payment_type', payload: ?string }
  | { type: 'change_step', payload: number }
  | { type: 'update_form', payload: {[key: string]: any} }
  | { type: 'toggle_express_donations', payload: boolean };

const initialState: FundraiserState = {
  amount: null,
  currency: 'USD',
  donationBands: {
    USD: [2, 5, 10, 25, 50],
    GBP: [1, 2, 3, 4, 5],
    EUR: [1, 2, 3, 4, 5],
    CAD: [1, 2, 3, 4, 5],
    AUD: [1, 2, 3, 4, 5],
    NZD: [1, 2, 3, 4, 5]
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

export default function fundraiserReducer(state: FundraiserState = initialState, action: FundraiserAction): FundraiserState {
  switch (action.type) {
    case 'parse_champaign_data':
      let donationBands;
      if (_.isEmpty(action.payload.fundraiser.donationBands)) {
        donationBands = state.donationBands;
      }
      else {
        donationBands = action.payload.fundraiser.donationBands;
      }

      return {
        ...state,
        ...action.payload.fundraiser,
        recurring: (action.payload.fundraiser.recurringDefault === 'only_recurring'),
        showExpressDonations: (action.payload.paymentMethods.length > 0),
        donationBands: donationBands
      };
    case 'reset_member':
      return {
        ...state,
        showExpressDonations: false,
        outstandingFields: state.fields.map(field => field.name),
        formValues: {},
      };
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
    case 'toggle_express_donations':
      return { ...state, showExpressDonations: action.payload };
    default:
      return state;
  }
}
