import { isEmpty, keys, pick, reduce } from 'lodash';
import ee from '../../shared/pub_sub';

import { isDirectDebitSupported } from '../../util/directDebitDecider';

const getLocalPaymentTypes = ({ country, recurring, currency }) => {
  const supportedList = [];

  if (currency !== 'EUR' || recurring) return supportedList;

  // IDEAL
  if (country === 'NL') supportedList.push('ideal');

  // GIROPAY
  if (country === 'DE') supportedList.push('giropay');

  return supportedList;
};

export const initialState = {
  currency: 'USD',
  currentPaymentType: 'ideal',
  currentStep: 0,
  showDirectDebit: false,
  showIdeal: false,
  directDebitOnly: false,
  disableSavedPayments: false,
  donationAmount: undefined,
  selectedAmountButton: null,
  isCustomAmount: false,
  donationBands: {
    USD: [2, 5, 10, 25, 50],
    GBP: [2, 5, 10, 25, 50],
    EUR: [2, 5, 10, 25, 50],
    CHF: [2, 5, 10, 25, 50],
    CAD: [2, 5, 10, 25, 50],
    AUD: [2, 5, 10, 25, 50],
    NZD: [2, 5, 10, 25, 50],
    MXN: [2, 5, 10, 25, 50],
    ARS: [2, 5, 10, 25, 50],
    BRL: [2, 5, 10, 25, 50],
  },
  fields: [],
  form: {},
  formId: '',
  formValues: {},
  oneClick: false,
  outstandingFields: [],
  paymentMethods: [],
  paymentTypes: ['card', 'paypal'],
  localPaymentTypes: [],
  preselectAmount: false,
  recurring: false,
  recurringDefault: 'one_off',
  storeInVault: false,
  submitting: false,
  oneClickError: false,
  title: '',
  supportedLocalCurrency: true,
  merchantAccounts: {
    USD: 'sumofus',
    GBP: 'sumofus2_GBP',
    EUR: 'sumofus2_EUR',
    CHF: 'SumOfUs_CHF',
    CAD: 'SumOfUs_CAD',
    AUD: 'SumOfUs_AUD',
    NZD: 'SumOfUs_NZD',
    MXN: 'SumOfUs_MXN',
    ARS: 'SumOfUs_ARS',
    BRL: 'SumOfUs_BRL',
  },
  merchantAccountId: 'sumofus',
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
        'oneClick',
        'donationAmount',
        'id_mismatch'
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
      const { preselectAmount, donationBands, merchantAccounts } = state;
      const currency = supportedCurrency(action.payload, keys(donationBands));
      const localPaymentTypes = getLocalPaymentTypes({
        country: state.form.country || state.formValues.country,
        recurring: state.recurring,
        currency: currency,
      });
      const merchantAccountId = merchantAccounts[currency.toUpperCase()];

      return {
        ...state,
        ...featuredAmountState(preselectAmount, { donationBands, currency }),
        currency,
        localPaymentTypes,
        merchantAccountId,
      };
    }
    case 'change_amount':
      const donationAmount = action.payload || undefined;
      return { ...state, donationAmount };
    case 'set_selected_amount_button':
      return { ...state, selectedAmountButton: action.payload };
    case 'one_click_failed':
      return { ...state, disableSavedPayments: true, oneClickError: true };
    case 'change_step':
      return { ...state, currentStep: action.payload };
    case 'set_is_custom_amount':
      return { ...state, isCustomAmount: action.payload };
    case 'update_form': {
      const form = action.payload;
      const showDirectDebit = isDirectDebitSupported({
        country: form.country,
        recurring: state.recurring,
      });
      const localPaymentTypes = getLocalPaymentTypes({
        country: form.country,
        recurring: state.recurring,
        currency: state.currency,
      });

      const paymentTypes = supportedPaymentTypes({
        showDirectDebit,
        localPaymentTypes,
        directDebitOnly: state.directDebitOnly,
      });
      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );
      return {
        ...state,
        form,
        showDirectDebit,
        localPaymentTypes,
        paymentTypes,
        currentPaymentType,
      };
    }
    case 'set_direct_debit_only': {
      const localPaymentTypes = getLocalPaymentTypes({
        country: state.form.country || state.formValues.country,
        recurring: action.payload,
        currency: state.currency,
      });

      const paymentTypes = supportedPaymentTypes({
        showDirectDebit: state.showDirectDebit,
        showIdeal: state.showIdeal,
        directDebitOnly: action.payload,
        localPaymentTypes,
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
      const label = state.currentPaymentType
        ? `from_${state.currentPaymentType}_to_${action.payload}`
        : action.payload;
      ee.emit('set_payment_type', label);
      return {
        ...state,
        currentPaymentType: safePaymentType(action.payload, state.paymentTypes),
      };
    case 'set_recurring': {
      const showDirectDebit = isDirectDebitSupported({
        country: state.form.country || state.formValues.country,
        recurring: action.payload,
      });

      const localPaymentTypes = getLocalPaymentTypes({
        country: state.form.country || state.formValues.country,
        recurring: action.payload,
        currency: state.currency,
      });

      const paymentTypes = supportedPaymentTypes({
        showDirectDebit,
        localPaymentTypes,
        directDebitOnly: state.directDebitOnly,
      });
      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );

      return {
        ...state,
        recurring: action.payload,
        showDirectDebit,
        localPaymentTypes,
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

      const localPaymentTypes = getLocalPaymentTypes({
        country: state.form.country || state.formValues.country,
        recurring: data.recurring,
        currency: state.currency,
      });

      const paymentTypes = supportedPaymentTypes({
        showDirectDebit,
        localPaymentTypes,
        directDebitOnly: state.directDebitOnly,
      });

      const currentPaymentType = safePaymentType(
        state.currentPaymentType,
        paymentTypes
      );
      return {
        ...state,
        ...data,
        showDirectDebit,
        localPaymentTypes,
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
      const localPaymentTypes = getLocalPaymentTypes({
        country: formValues.country,
        recurring: state.recurring,
        currenct: state.currency,
      });

      const paymentTypes = supportedPaymentTypes({
        showDirectDebit,
        localPaymentTypes,
        directDebitOnly: state.directDebitOnly,
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
        localPaymentTypes,
        currentPaymentType,
      };
    }
    case 'set_supported_local_currency':
      return { ...state, supportedLocalCurrency: action.payload };
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
  let list = [];
  if (data.localPaymentTypes?.length > 0) list = data.localPaymentTypes;
  if (data.showDirectDebit) list.push('gocardless');
  if (!data.directDebitOnly) list.push('paypal', 'card');
  return list;
}

function safePaymentType(pt, pts) {
  return pts.includes(pt) ? pt : pts[0];
}
