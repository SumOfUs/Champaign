/* @flow */
import { keys, includes, isEmpty, without, pick } from 'lodash';
import {
  initialState,
  recurringState,
  supportedCurrency,
  pickMedianAmount,
  featuredAmountState,
} from './helpers';
import type { FundraiserAction as Action } from './actions';
import type { Fundraiser as State, DonationBands } from './helpers';

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
      return { ...state, ...initialData };
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
    case 'append_custom':
      return {
        ...state,
        customData: Object.assign({}, action.payload, state.customData),
      };
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
