import React from 'react';
import configureStore from '../../state';
import { Provider } from 'react-redux';
import FundraiserView from './FundraiserView';
import { changeStep } from '../../state/fundraiser/actions';
import { mountWithIntl } from '../../../../spec/jest/intl-enzyme-test-helpers';

import type {
  FundraiserAction,
  FundraiserInitializationOptions,
} from '../../state/fundraiser/types';

global.fbq = () => null;

const suite = {};

const fundraiserDefaults = {
  fields: [
    {
      id: 771,
      form_id: 180,
      label: 'Email Address',
      data_type: 'email',
      default_value: null,
      required: true,
      visible: null,
      name: 'email',
      position: 0,
      choices: [],
      display_mode: 'all_members',
    },
    {
      id: 772,
      form_id: 180,
      label: 'Full name',
      data_type: 'text',
      default_value: null,
      required: true,
      visible: null,
      name: 'name',
      position: 1,
      choices: [],
      display_mode: 'all_members',
    },
    {
      id: 773,
      form_id: 180,
      label: 'Country',
      data_type: 'country',
      default_value: null,
      required: false,
      visible: null,
      name: 'country',
      position: 2,
      choices: [],
      display_mode: 'recognized_members_only',
    },
  ],
  formId: 180,
  formValues: {},
  outstandingFields: ['email', 'name', 'country'],
  donationBands: {},
};

const mountView = () => {
  return mountWithIntl(
    <Provider store={suite.store}>
      <FundraiserView />
    </Provider>
  );
};

const cardMethod = {
  id: 17,
  last_4: '1111',
  instrument_type: 'credit_card',
  card_type: 'Visa',
  email: null,
  token: '5gr378',
};

const paypalMethod = {
  id: 19,
  last_4: null,
  instrument_type: 'paypal_account',
  card_type: null,
  email: 'payer@example.com',
  token: '5qnwgp',
};

const fetchInitialState = vals => {
  const defaults = {
    paymentMethods: [],
    locale: 'en',
    member: {},
    location: {},
    fundraiser: {
      currency: 'USD',
      donationAmount: null,
      donationBands: fundraiserDefaults.donationBands,
      formValues: fundraiserDefaults.formValues,
      formId: fundraiserDefaults.formId,
      outstandingFields: fundraiserDefaults.outstandingFields,
      title: 'Gimme the loot',
      fields: fundraiserDefaults.fields,
      recurringDefault: 'one_off',
      preselectAmount: false,
    },
  };
  vals = vals || {};
  return {
    page: {
      id: '1',
      title: 'Test Title',
      action_count: 0,
      allow_duplicate_actions: false,
      canonical_url: '',
      created_at: '',
      featured: false,
      follow_up_page_id: 0,
      follow_up_plan: 'with_liquid',
      language_id: 1,
      optimizely_status: 'optimizely_disabled',
      primary_image_id: 0,
      publish_status: 'unpublished',
      slug: '',
      status: 'pending',
      updated_at: '',
    },
    personalization: {
      paymentMethods: vals.paymentMethods || defaults.paymentMethods,
      member: vals.member || defaults.member,
      locale: vals.locale || defaults.locale,
      location: vals.location || defaults.location,
      fundraiser: {
        ...defaults.fundraiser,
        ...vals,
      },
      donationsThermometer: {
        id: 10,
        title: null,
        offset: 0,
        page_id: 2,
        active: true,
        created_at: '2018-11-22T17:58:09.748Z',
        updated_at: '2018-11-22T17:58:32.582Z',
        ref: '',
        type: 'DonationsThermometer',
        percentage: 0,
        remaining_amounts: {
          USD: -90,
          GBP: -90,
          EUR: -90,
          CHF: -90,
          AUD: -90,
          NZD: -90,
          CAD: -90,
        },
        total_donations: {
          USD: 10,
          GBP: 10,
          EUR: 10,
          CHF: 10,
          AUD: 10,
          NZD: 10,
          CAD: 10,
        },
        goals: {
          USD: 100,
          GBP: 100,
          EUR: 100,
          CHF: 100,
          AUD: 100,
          NZD: 100,
          CAD: 100,
        },
      },
    },
  };
};

const initialize = vals => {
  const data = fetchInitialState(vals);
  suite.store = configureStore(data);
  const {
    donationBands,
    currency,
    preselectAmount,
    recurringDefault,
  } = data.personalization.fundraiser;

  suite.store.dispatch({
    type: 'initialize_fundraiser',
    payload: data.personalization.fundraiser,
  });

  suite.store.dispatch({
    type: 'set_donation_bands',
    payload: donationBands,
  });

  suite.store.dispatch({
    type: 'change_currency',
    payload: currency,
  });

  suite.store.dispatch({
    type: 'preselect_amount',
    payload: preselectAmount,
  });

  suite.store.dispatch({
    type: 'set_recurring_defaults',
    payload: recurringDefault,
  });

  suite.wrapper = mountView();
};

describe('Initial rendering', function() {
  it('begins on the first step', () => {
    initialize();
    expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(0); // 0 index
  });

  it('skips the first step when initialized with a default amount', () => {
    initialize({ donationAmount: 12 });
    expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1); // 0 index, 1 is second step
  });

  it('only shows two step circles when outstandingFields is empty', () => {
    initialize({ outstandingFields: [] });
    expect(suite.wrapper.find('Step').length).toEqual(2);
  });

  it('does not render form step when outstandingFields is empty', () => {
    initialize({ outstandingFields: [] });
    expect(suite.wrapper.find('StepContent').length).toEqual(2);
    expect(suite.wrapper.find('MemberDetailsForm').length).toEqual(0);
  });

  it('begins on the third step when amount is passed and outstandingFields is empty', () => {
    initialize({ outstandingFields: [], donationAmount: 5 });
    // 0 index, 1 is third step when seconds step is hidden
    expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
    const lastStep = suite.wrapper.find('StepContent').last();
    expect(lastStep.prop('title').props['id']).toEqual('fundraiser.payment');
    expect(lastStep.prop('visible')).toEqual(true);
  });
});

describe('Donation Amount Tab', function() {
  describe('Initial state', () => {
    it('shows a default donation band', () => {
      initialize({ donationBands: {} });
      expect(suite.wrapper.find('DonationBands').find('Button').length).toEqual(
        5
      );
    });

    it('formats the donation amounts with the current currency', () => {
      initialize({ currency: 'GBP' });
      const labels = suite.wrapper
        .find('DonationBands')
        .find('Button')
        .map(node => node.text());
      expect(labels).toEqual(['£2', '£5', '£10', '£25', '£50']);
    });

    it('shows a donation band passed as an argument', () => {
      initialize({
        donationBands: { USD: [1, 2, 3, 4, 5, 6, 7] },
        currency: 'USD',
      });
      const labels = suite.wrapper
        .find('DonationBands')
        .find('Button')
        .map(node => node.text());
      expect(labels).toEqual(['$1', '$2', '$3', '$4', '$5', '$6', '$7']);
    });
  });

  describe('UI interactions:', () => {
    beforeEach(() => {
      initialize();
    });

    // selecting amounts
    it('updates the selected amount when we click on a DonationBand button', () => {
      suite.wrapper
        .find('DonationBands')
        .find('Button')
        .first()
        .simulate('click');
      expect(
        suite.wrapper.find('FundraiserView').prop('fundraiser').donationAmount
      ).toEqual(2);
      expect(
        suite.wrapper
          .find('Step')
          .find('CurrencyAmount')
          .text()
      ).toEqual('$2');
    });

    it('updates the selected amount when we use the custom input box', () => {
      suite.wrapper.find('#DonationBands-custom-amount').simulate('focus');
      const el = suite.wrapper.find('#DonationBands-custom-amount');
      el.getDOMNode().value = 8;
      el.simulate('change');
      expect(
        suite.wrapper.find('FundraiserView').prop('fundraiser').donationAmount
      ).toEqual(8);
      expect(
        suite.wrapper
          .find('Step')
          .find('CurrencyAmount')
          .text()
      ).toEqual('$8');
    });

    // changing the currency
    it('reveals a currency dropdown when we click on the "Change currency" link', () => {
      expect(
        suite.wrapper.find('.AmountSelection__currency-selector').length
      ).toEqual(0);
      suite.wrapper.find('.AmountSelection__currency-toggle').simulate('click');
      expect(
        suite.wrapper.find('.AmountSelection__currency-selector').length
      ).toEqual(1);
    });

    it('changes the currency when we select a currency from the dropdown', () => {
      expect(
        suite.wrapper.find('FundraiserView').prop('fundraiser').currency
      ).toEqual('USD');
      suite.wrapper.find('.AmountSelection__currency-toggle').simulate('click');
      const el = suite.wrapper.find('.AmountSelection__currency-selector');
      el.getDOMNode().value = 'GBP';
      el.simulate('change');
      expect(
        suite.wrapper.find('FundraiserView').prop('fundraiser').currency
      ).toEqual('GBP');
    });

    it('updates the currency symbols in outputs to match the selected currency format', () => {
      // assert initial state
      let labels = suite.wrapper
        .find('DonationBands')
        .find('Button')
        .map(node => node.text());
      expect(labels).toEqual(['$2', '$5', '$10', '$25', '$50']);

      // interaction
      suite.wrapper.find('FundraiserView').prop('selectCurrency')('GBP');

      // outcome
      labels = suite.wrapper
        .find('DonationBands')
        .find('Button')
        .map(node => node.text());
      expect(labels).toEqual(['£2', '£5', '£10', '£25', '£50']);
    });

    // transitioning
    it('transitions to the next step when we click an amount button', () => {
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(0);
      suite.wrapper
        .find('DonationBandButton')
        .first()
        .simulate('click');
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
    });

    it('transitions to the next step when we click proceed with an amount entered', () => {
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(0);
      suite.wrapper.find('#DonationBands-custom-amount').simulate('focus');
      const el = suite.wrapper.find('#DonationBands-custom-amount');
      el.getDOMNode().value = '8';
      el.simulate('change');
      suite.wrapper
        .find('Button.AmountSelection__proceed-button')
        .simulate('click');
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
    });
  });
});

describe('Payment Panel', function() {
  describe('Initial state', () => {
    it("displays the user's name if they are logged in", () => {
      initialize({
        member: { email: 'asdf@gmail.com', name: 'As Df', country: 'US' },
        outstandingFields: [],
        donationAmount: 5,
      });
      expect(suite.wrapper.find('.WelcomeMember').length).toEqual(1);
      expect(suite.wrapper.find('.WelcomeMember__name').text()).toEqual(
        'As Df'
      );
    });

    it("displays the user's email if they are logged in but have no name", () => {
      initialize({
        member: { email: 'asdf@gmail.com', country: 'US' },
        outstandingFields: [],
        donationAmount: 5,
      });
      expect(suite.wrapper.find('.WelcomeMember').length).toEqual(1);
      expect(suite.wrapper.find('.WelcomeMember__name').text()).toEqual(
        'asdf@gmail.com'
      );
    });

    it('does not display the user panel if no user known', () => {
      initialize({ outstandingFields: [], member: {}, donationAmount: 5 });
      expect(suite.wrapper.find('.WelcomeMember').length).toEqual(0);
    });

    it('does not display the user panel if user known but step 2 is displayed', () => {
      initialize({
        outstandingFields: ['texting_opt_in'],
        donationAmount: 5,
        member: { email: 'asdf@gmail.com' },
      });
      expect(suite.wrapper.find('.WelcomeMember').length).toEqual(0);
    });

    it('displays the new payment method form when no known payment methods', () => {
      initialize({ outstandingFields: [], donationAmount: 2 });
      expect(
        suite.wrapper.find('.ShowIf--hidden').find('PaymentTypeSelection')
          .length
      ).toEqual(0);
      expect(
        suite.wrapper.find('.ShowIf--visible').find('PaymentTypeSelection')
          .length
      ).toEqual(1);
      expect(suite.wrapper.find('PayPal').length).toEqual(1);
      expect(suite.wrapper.find('BraintreeCardFields').length).toEqual(1);
      // expect(suite.wrapper.find('DonateButton').length).toEqual(1);
    });

    it('does not display the new payment method form when there are known payment methods', () => {
      initialize({
        outstandingFields: [],
        donationAmount: 2,
        paymentMethods: [cardMethod],
      });
      expect(
        suite.wrapper.find('.ShowIf--hidden').find('PaymentTypeSelection')
          .length
      ).toEqual(1);
      expect(suite.wrapper.find('PaymentTypeSelection').length).toEqual(1); // check that's the only one
    });

    it('displays saved payment options as a list of radio buttons', () => {
      initialize({
        outstandingFields: [],
        donationAmount: 13,
        paymentMethods: [cardMethod, paypalMethod],
      });
      expect(
        suite.wrapper.find(
          '.ExpressDonation .PaymentMethod input[type="radio"]'
        ).length
      ).toEqual(2);
    });

    it('displays just one payment option if only one exists', () => {
      initialize({
        outstandingFields: [],
        donationAmount: 13,
        paymentMethods: [cardMethod],
      });
      expect(
        suite.wrapper.find(
          '.ExpressDonation .PaymentMethod input[type="radio"]'
        ).length
      ).toEqual(0);
      expect(
        suite.wrapper.find('.ExpressDonation__single-item').length
      ).toEqual(1);
    });

    it('displays the GoCardless button when in a Direct Debit Country', () => {
      initialize({
        outstandingFields: [],
        donationAmount: 2,
        formValues: { country: 'DE' },
      });
      expect(
        suite.wrapper.find(
          '.PaymentTypeSelection__payment-methods .PaymentMethod input[type="radio"]'
        ).length
      ).toEqual(3);
    });

    it('displays the GoCardless button when in a recurring Direct Debit Country', () => {
      initialize({
        outstandingFields: [],
        donationAmount: 2,
        formValues: { country: 'GB' },
        recurringDefault: 'recurring',
      });
      expect(
        suite.wrapper.find(
          '.PaymentTypeSelection__payment-methods .PaymentMethod input[type="radio"]'
        ).length
      ).toEqual(3);
    });

    it('does not display the GoCardless button when not in a direct debit country', () => {
      initialize({
        outstandingFields: [],
        donationAmount: 2,
        formValues: { country: 'CA' },
      });
      expect(
        suite.wrapper.find(
          '.PaymentTypeSelection__payment-methods .PaymentMethod input[type="radio"]'
        ).length
      ).toEqual(2);
    });
  });

  describe('UI interactions', () => {
    describe('clicking sign-out button', () => {
      beforeEach(() => {
        suite.memberVals = { email: 'asdf@gmail.com', name: 'As Df' };
        initialize({
          outstandingFields: [],
          paymentMethods: [cardMethod, paypalMethod],
          member: suite.memberVals,
          formValues: suite.memberVals,
          donationAmount: 4,
        });
      });

      it('returns to step 2', () => {
        expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
        expect(suite.wrapper.find('StepContent').length).toEqual(2);
        expect(
          suite.wrapper
            .find('.StepContent')
            .last()
            .hasClass('StepContent-hidden')
        ).toEqual(false);

        suite.wrapper.find('.WelcomeMember__link').simulate('click');

        expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
        expect(suite.wrapper.find('StepContent').length).toEqual(3);
        expect(
          suite.wrapper
            .find('.StepContent')
            .last()
            .hasClass('StepContent-hidden')
        ).toEqual(true);
      });

      it('hides the saved payment methods', () => {
        expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
        expect(suite.wrapper.find('.ExpressDonation').length).toEqual(1);
        suite.wrapper.find('.WelcomeMember__link').simulate('click');
        expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);

        suite.store.dispatch(changeStep(2));
        suite.wrapper.update();
        expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(2);
        expect(suite.wrapper.find('.ExpressDonation').length).toEqual(0);
      });

      it('clears the formValues', () => {
        expect(
          suite.wrapper.find('FundraiserView').prop('fundraiser').formValues
        ).toEqual(suite.memberVals);
        suite.wrapper.find('.WelcomeMember__link').simulate('click');
        expect(
          suite.wrapper.find('FundraiserView').prop('fundraiser').formValues
        ).toEqual({});
      });
    });
  });
});
