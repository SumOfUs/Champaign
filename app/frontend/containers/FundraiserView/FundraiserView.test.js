/* @flow */
import React from 'react';
import { mount } from 'enzyme';
import configureStore from '../../state';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';
import FundraiserView, { mapStateToProps, mapDispatchToProps } from './FundraiserView';

const suite = {};

const fundraiserDefaults = {
  fields: [
  ],
  formId: 180,
  formValues: {},
  outstandingFields: ['email', 'name', 'country'],
  donationBands: {},
}

const mountView = () => {
  return mount(
    <Provider store={suite.store}>
      <IntlProvider locale="en">
        <FundraiserView />
      </IntlProvider>
    </Provider>
  );
}

const fetchInitialState = (vals) => {
  vals = vals || {};
  return {
    paymentMethods: vals.paymentMethods || [],
    member: vals.member || {},
    locale: vals.locale || 'en',
    fundraiser: {
      pageId: vals.pageId || '65',
      currency: vals.currency || 'USD',
      amount: vals.amount || null,
      donationBands: vals.donationBands || fundraiserDefaults.donationBands,
      showDirectDebit: vals.showDirectDebit || false,
      formValues: vals.formValues || fundraiserDefaults.formValues,
      formId: vals.formId || fundraiserDefaults.formId,
      outstandingFields: vals.outstandingFields || fundraiserDefaults.outstandingFields,
      title: vals.title || 'Gimme the loot',
      fields: vals.fields || [],
      recurringDefault: vals.recurringDefault || 'one_off',
    }
  }
};

const initialize = (vals) => {
  suite.store = configureStore();
  suite.store.dispatch({ type: 'parse_champaign_data', payload: fetchInitialState(vals) });
  suite.wrapper = mountView();
}

describe('Initial rendering', function () {

  it('begins on the first step', () => {
    initialize();
    expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(0); // 0 index
  });

  it('skips the first step when initialized with a default amount', () => {
    initialize({amount: 12});
    expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1); // 0 index, 1 is second step
  });

  it('only shows two step circles when outstandingFields is empty', () => {
    initialize({outstandingFields: []});
    expect(suite.wrapper.find('Step').length).toEqual(2);
  });

  it('does not render form step when outstandingFields is empty', () => {
    initialize({outstandingFields: []});
    expect(suite.wrapper.find('StepContent').length).toEqual(2);
    expect(suite.wrapper.find('MemberDetailsForm').length).toEqual(0);
  });

  it('begins on the third step when amount is passed and outstandingFields is empty', () => {
    initialize({outstandingFields: [], amount: 5});
     // 0 index, 1 is third step when seconds step is hidden
    expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
    const lastStep = suite.wrapper.find('StepContent').last();
    expect(lastStep.prop('title')).toEqual('payment');
    expect(lastStep.prop('visible')).toEqual(true);
  });
});

describe('Donation Amount Tab', function () {

  describe('Initial state', () => {

    it('shows a default donation band', () => {
      initialize({ donationBands: {}});
      expect(suite.wrapper.find('DonationBands').find('Button').length).toEqual(5);
    });

    it('formats the donation amounts with the current currency', () => {
      initialize({ currency: 'GBP'});
      const labels = suite.wrapper.find('DonationBands').find('Button').map(node => node.text());
      expect(labels).toEqual(['£2', '£5', '£10', '£25', '£50']);
    });

    it('shows a donation band passed as an argument', () => {
      initialize({ donationBands: { USD: [1, 2, 3, 4, 5, 6, 7] }, currency: 'USD'});
      const labels = suite.wrapper.find('DonationBands').find('Button').map(node => node.text());
      expect(labels).toEqual(['$1', '$2', '$3', '$4', '$5', '$6', '$7']);
    });

    it('does not show the currency menu', () => {
      initialize();
      expect(suite.wrapper.find('AmountSelection').find('select').length).toEqual(0);
    });

    it('does not show the "Proceed" button', () => {
      initialize();
      expect(suite.wrapper.find('.AmountSelection__proceed-button').length).toEqual(0);
    });
  });

  describe('UI interactions:', () => {

    beforeEach(() => {
      initialize();
    });

    // selecting amounts
    it('updates the selected amount when we click on a DonationBand button', () => {
      suite.wrapper.find('DonationBands').find('Button').first().simulate('click');
      expect(suite.wrapper.find('FundraiserView').prop('fundraiser').donationAmount).toEqual(2);
      expect(suite.wrapper.find('Step').find('FormattedNumber').text()).toEqual('$2');
    });

    it('updates the selected amount when we use the custom input box', () => {
      suite.wrapper.find('#DonationBands-custom-amount').simulate('focus');
      suite.wrapper.find('#DonationBands-custom-amount').simulate('change', {target: {value: '8'}});
      expect(suite.wrapper.find('FundraiserView').prop('fundraiser').donationAmount).toEqual(8);
      expect(suite.wrapper.find('Step').find('FormattedNumber').text()).toEqual('$8');
    });

    it('shows a "Proceed" button when the custom amount input is used', () => {
      expect(suite.wrapper.find('.AmountSelection__proceed-button').length).toEqual(0);
      suite.wrapper.find('#DonationBands-custom-amount').simulate('focus');
      suite.wrapper.find('#DonationBands-custom-amount').simulate('change', {target: {value: '8'}});
      expect(suite.wrapper.find('.AmountSelection__proceed-button').length).toEqual(1);
      expect(suite.wrapper.find('.AmountSelection__proceed-button').prop('disabled')).toEqual(false);
    });


    // changing the currency
    it('reveals a currency dropdown when we click on the "Change currency" link', () => {
      expect(suite.wrapper.find('.AmountSelection__currency-selector').length).toEqual(0);
      suite.wrapper.find('.AmountSelection__currency-toggle').simulate('click');
      expect(suite.wrapper.find('.AmountSelection__currency-selector').length).toEqual(1);
    });

    it('changes the currency when we select a currency from the dropdown', () => {
      expect(suite.wrapper.find('FundraiserView').prop('fundraiser').currency).toEqual('USD');
      suite.wrapper.find('.AmountSelection__currency-toggle').simulate('click');
      suite.wrapper.find('.AmountSelection__currency-selector').simulate('change', {target: {value: 'GBP'}});
      expect(suite.wrapper.find('FundraiserView').prop('fundraiser').currency).toEqual('GBP');
    });

    it('updates the currency symbols in outputs to match the selected currency format', () => {
      // assert initial state
      let labels = suite.wrapper.find('DonationBands').find('Button').map(node => node.text());
      expect(labels).toEqual(['$2', '$5', '$10', '$25', '$50']);

      // interaction
      suite.wrapper.find('#DonationBands-custom-amount').simulate('focus');
      suite.wrapper.find('#DonationBands-custom-amount').simulate('change', {target: {value: '8'}});
      suite.wrapper.find('.AmountSelection__currency-toggle').simulate('click');
      suite.wrapper.find('.AmountSelection__currency-selector').simulate('change', {target: {value: 'GBP'}});

      // outcome
      labels = suite.wrapper.find('DonationBands').find('Button').map(node => node.text());
      expect(labels).toEqual(['£2', '£5', '£10', '£25', '£50']);
      expect(suite.wrapper.find('Step').find('FormattedNumber').text()).toEqual('£8');
      expect(suite.wrapper.find('#DonationBands-custom-amount').prop('value')).toEqual('£8');
    });

    // transitioning
    it('transitions to the next step when we click an amount button', () => {
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(0);
      suite.wrapper.find('DonationBands').find('Button').first().simulate('click');
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
    });

    it('transitions to the next step when we click an amount button', () => {
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(0);
      suite.wrapper.find('#DonationBands-custom-amount').simulate('focus');
      suite.wrapper.find('#DonationBands-custom-amount').simulate('change', {target: {value: '8'}});
      suite.wrapper.find('.AmountSelection__proceed-button').simulate('click');
      expect(suite.wrapper.find('Stepper').prop('currentStep')).toEqual(1);
    });

  });
});

describe('mapStateToProps', function () {
  let stateFromProps: Object = {};
  beforeEach(() => stateFromProps = mapStateToProps(configureStore().getState()));

  it.skip('returns member from state', () => {
    expect(stateFromProps.formData.member).toBe(null);
  });

  it.skip('returns the list of currencies from state', () => {
    expect(stateFromProps.fundraiser.currencies.length).toBe(6);
  });

  it.skip('returns donationBands from state', () => {
    expect(stateFromProps.fundraiser.donationBands.length).toBe(5);
  });

  it.skip('returns currently selected donation amount', () => {
    expect(stateFromProps.fundraiser.donationAmount).toBe(null);
  });
});

describe('mapDispatchToProps', function () {
  const dispatch = jest.fn();
  const props = mapDispatchToProps(dispatch);

  it('.selectAmount dispatches `changeAmount`', () => {
    props.selectAmount(1);
    expect(dispatch).toHaveBeenCalledWith({ type: 'change_amount', payload: 1 });
  });

  it('.selectCurrency dispatches `changeCurrency`', () => {
    props.selectCurrency('USD'); expect(dispatch).toHaveBeenCalledWith({ type: 'change_currency', payload: 'USD' });
  });
});
