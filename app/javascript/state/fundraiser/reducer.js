/* @flow */
import { includes, isEmpty, without } from 'lodash';
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
    case 'parse_champaign_data': {
      const { fundraiser } = action.payload;
      const { currency, donationBands, recurringDefault } = fundraiser;
      const amounts = isEmpty(donationBands)
        ? state.donationBands
        : donationBands;

      return Object.assign({}, state, fundraiser, {
        currency: supportedCurrency(currency, Object.keys(donationBands)),
        donationBands: amounts,
        ...featuredAmountState({ ...state, donationBands: amounts }, currency),
        ...recurringState(recurringDefault),
      });
    }
    case 'querystring_parameters': {
      const { amount, recurring_default, preselect } = action.payload;
      const currency = supportedCurrency(
        action.payload.currency,
        Object.keys(state.donationBands)
      );
      return Object.assign(state, {
        donationAmount: parseInt(amount, 10) || 0,
        currency,
        ...recurringState(recurring_default),
        ...featuredAmountState(state, currency, preselect),
      });
    }
    case 'reset_member':
      return Object.assign({}, state, {
        outstandingFields: state.fields.map(field => field.name),
        formValues: {},
      });
    case 'set_submitting':
      return Object.assign({}, state, {
        submitting: action.payload,
      });
    case 'change_currency': {
      const currency = supportedCurrency(
        action.payload,
        Object.keys(state.donationBands)
      );

      return {
        ...state,
        ...featuredAmountState(state, currency),
        currency,
      };
    }

    case 'change_amount':
      return Object.assign({}, state, {
        donationAmount: action.payload || undefined,
      });
    case 'change_step':
      return Object.assign({}, state, {
        currentStep: action.payload,
      });
    case 'proceed_step':
      const nextStep = state.currentStep + 1;
      return Object.assign({}, state, {
        currentStep: nextStep,
      });
    case 'update_form':
      return Object.assign({}, state, {
        form: action.payload,
      });
    case 'set_store_in_vault':
      return Object.assign({}, state, {
        storeInVault: action.payload,
      });
    case 'set_payment_type':
      return Object.assign({}, state, {
        currentPaymentType: action.payload,
      });
    case 'set_recurring':
      return Object.assign({}, state, {
        recurring: action.payload,
      });
    default:
      return state;
  }
};
