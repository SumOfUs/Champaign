/* @flow */
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
  fields: {},
  formId: 4,
  user: {
    email: '',
    name: '',
    country: '',
    postal: '',
  },
  form: {},
};

export function fundraiserReducer(state: FundraiserState = initialState, action: FundraiserAction): FundraiserState {
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
