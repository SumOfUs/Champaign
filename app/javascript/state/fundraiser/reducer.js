import {
  compact,
  includes,
  isEmpty,
  keys,
  pick,
  reduce,
  without,
} from 'lodash';

import { isDirectDebitSupported } from '../../util/directDebitDecider';

export const initialState = {
  currency: 'USD',
  currentPaymentType: 'card',
  currentStep: 0,
  showDirectDebit: false,
  directDebitOnly: false,
  disableSavedPayments: false,
  donationAmount: undefined,
  donationBands: {
    USD: [2, 5, 10, 25, 50],
    GBP: [2, 5, 10, 25, 50],
    EUR: [2, 5, 10, 25, 50],
    CHF: [2, 5, 10, 25, 50],
    CAD: [2, 5, 10, 25, 50],
    AUD: [2, 5, 10, 25, 50],
    NZD: [2, 5, 10, 25, 50],
  },
  fields: [],
  form: {},
  formId: '',
  formValues: {},
  freestanding: false,
  oneClick: false,
  outstandingFields: [],
  paymentMethods: [],
  paymentTypes: ['card', 'paypal'],
  preselectAmount: false,
  recurring: false,
  recurringDefault: 'one_off',
  storeInVault: false,
  submitting: false,
  oneClickError: false,
  title: '',
};

export default (state = initialState, action) => {
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
        'oneClick',
        'donationAmount'
      );
      initialData.formValues = initialData.formValues || {};
      return {
        ...state,
        ...initialData,
        paymentTypes: ['paypal', 'card'],
      };
    case 'search_string_overrides':
      return searchStringOverrides(state, action.payload);
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
    case 'one_click_failed':
      return { ...state, disableSavedPayments: true, oneClickError: true };
    case 'change_step':
      return { ...state, currentStep: action.payload };
    case 'update_form': {
      const form = action.payload;
      const showDirectDebit = isDirectDebitSupported({
        country: form.country,
        recurring: state.recurring,
      });
      const paymentTypes = supportedPaymentTypes({
        showDirectDebit,
        directDebitOnly: state.directDebitOnly,
        recurring: state.recurring,
      });
      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );
      return {
        ...state,
        form,
        showDirectDebit,
        paymentTypes,
        currentPaymentType,
      };
    }
    case 'set_direct_debit_only': {
      const paymentTypes = supportedPaymentTypes({
        showDirectDebit: state.showDirectDebit,
        directDebitOnly: action.payload,
        recurring: state.recurring,
      });
      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );

      return {
        ...state,
        directDebitOnly: action.payload,
        paymentTypes,
        currentPaymentType,
      };
    }
    case 'set_donation_bands':
      const payload = action.payload;
      const donationBands = isEmpty(payload) ? state.donationBands : payload;
      const currency = supportedCurrency(state.currency, keys(donationBands));
      const preselectAmount = state.preselectAmount;
      return {
        ...state,
        ...featuredAmountState(preselectAmount, { donationBands, currency }),
        currency,
        donationBands,
      };
    case 'set_payment_type':
      return {
        ...state,
        currentPaymentType: safePaymentType(action.payload, state.paymentTypes),
      };
    case 'set_recurring': {
      const showDirectDebit = isDirectDebitSupported({
        country: state.form.country || state.formValues.country,
        recurring: action.payload,
      });
      const paymentTypes = supportedPaymentTypes({
        showDirectDebit,
        directDebitOnly: state.directDebitOnly,
        recurring: action.payload,
      });
      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );

      return {
        ...state,
        recurring: action.payload,
        showDirectDebit,
        paymentTypes,
        currentPaymentType,
      };
    }
    case 'set_recurring_defaults': {
      const data = recurringState(action.payload);
      const showDirectDebit = isDirectDebitSupported({
        country: state.form.country || state.formValues.country,
        recurring: data.recurring,
      });
      const paymentTypes = supportedPaymentTypes({
        showDirectDebit,
        directDebitOnly: state.directDebitOnly,
        recurring: data.recurring,
      });
      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );
      return {
        ...state,
        ...data,
        showDirectDebit,
        paymentTypes,
        currentPaymentType,
      };
    }
    case 'set_store_in_vault':
      return { ...state, storeInVault: action.payload };
    case 'set_submitting':
      return { ...state, submitting: action.payload };
    case 'preselect_amount':
      return {
        ...state,
        ...featuredAmountState(action.payload, {
          donationBands: state.donationBands,
          currency: state.currency,
        }),
      };
    // Update our form with data from another form
    // E.g. petition was signed, so we can re-use the data from that form in
    // this form.
    case '@@chmp:action_form:updated': {
      const relevantFields = state.fields.map(field => field.name);
      const formValues = pick(action.payload, relevantFields);
      const form = formValues;
      const outstandingFields = relevantFields.filter(key => !formValues[key]);
      const showDirectDebit = isDirectDebitSupported({
        country: formValues.country,
        recurring: state.recurring,
      });
      const paymentTypes = supportedPaymentTypes({
        showDirectDebit: showDirectDebit,
        directDebitOnly: state.directDebitOnly,
        recurring: state.recurring,
      });
      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );
      return {
        ...state,
        form,
        formValues,
        outstandingFields,
        paymentTypes,
        currentPaymentType,
      };
    }
    default:
      return state;
  }
};

export const RECURRING_DEFAULTS = ['one_off', 'recurring', 'only_recurring'];

// `supportedCurrency` gets a currency string and compares it against our list of supported currencies.
// If our currency is not in the list of supported currencies, it will return the default currency (which,
// by default, is the first currency in our supoortedCurrencies list)
export function supportedCurrency(
  currency,
  currencies = Object.keys(initialState.donationBands)
) {
  return currencies.find(c => c === currency) || currencies[0];
}

export function recurringState(recurringValue = '') {
  const recurringDefault =
    RECURRING_DEFAULTS.find(i => i === recurringValue.toLowerCase()) ||
    'one_off';
  return {
    recurring: recurringDefault !== 'one_off',
    recurringDefault,
  };
}

export function pickMedianAmount(bands, currency) {
  const amounts = bands[currency];
  return amounts[Math.floor(amounts.length / 2)] || 0;
}

export function featuredAmountState(preselectAmount, state) {
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
  hide_spm: function hideSavedPayments(state, value) {
    if (value === '1') return { ...state, disableSavedPayments: true };
    else return state;
  },
};

// Overrides state values based on url query/search string (highest priority)
export function searchStringOverrides(state, search) {
  const handlers = pick(searchStringHandlers, keys(search));
  return reduce(handlers, (res, handler, k) => handler(res, search[k]), state);
}

function supportedPaymentTypes(data) {
  const list = [];
  if (data.showDirectDebit) list.push('gocardless');
  if (!data.directDebitOnly) list.push('paypal', 'card');
  return list;
}

function safePaymentType(pt, pts) {
  return pts.includes(pt) ? pt : pts[0];
}
