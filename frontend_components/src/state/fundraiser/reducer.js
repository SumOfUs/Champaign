/* @flow */

const initialState: FundraiserState = {
  amount: null,
  currency: 'USD',
  currencies: ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'NZD'],
  donationBands: [1, 2, 5, 10, 25],
  donationAmount: null,
  currentStep: 0,
  recurring: false,
  storeInVault: false,
  formId: 4,
  user: {
    email: '',
    name: '',
    country: '',
    postal: '',
  },
  form: {
    amount: null,
    paymentMethodNonce: null,
    currency: null,
    recurring: false,
    storeInVault: false,
    deviceData: {},
  }
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
    case 'update_form_member':
      return { ...state, user: action.payload };
    case 'set_store_in_vault':
      return { ...state, storeInVault: action.payload };
    case 'set_recurring':
      return { ...state, recurring: action.payload };
    default:
      return state;
  }
}
