/* @flow */

export type FormMember = {
  formId: ?number;
  email: ?string;
  name: ?string;
  country: ?string;
  postal: ?string;
};

export type FundraiserForm = {
  amount: ?number;
  user: FormMember;
  currency: ?string;
  recurring: boolean;
  storeInVault: boolean;
  paymentMethodNonce: ?string;
  deviceData: Object;
};

type FundraiserAction =
  { type: 'change_step', payload: number }
  | { type: 'proceed_step' };

// Reducer
const initialState: FundraiserState = {
  amount: null,
  currency: 'USD',
  currencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'NZD'],
  donationBands: [1, 2, 5, 10, 25],
  donationAmount: null,
  currentStep: 0,
  recurring: false,
  storeInVault: false,
  formId: null,
  user: {
    email: null,
    name: null,
    country: null,
    postal: null,
  },
};

export function fundraiserReducer(state: FundraiserState = initialState, action: FundraiserAction): FundraiserState {
  switch (action.type) {
    case 'change_currency':
      return { ...state, currency: action.payload };
    case 'change_amount':
      return { ...state, donationAmount: action.payload || null };
    case 'change_step':
      return { ...state, currentStep: action.payload };
    case 'proceed_step':
      const nextStep = state.currentStep + 1;
      return { ...state, currentStep: nextStep };
    case 'set_store_in_vault':
      return { ...state, storeInVault: action.payload };
    case 'set_recurring':
      return { ...state, recurring: action.payload };
    default:
      return state;
  }
}
