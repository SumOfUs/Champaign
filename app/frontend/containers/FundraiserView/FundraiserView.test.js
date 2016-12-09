/* @flow */
import React from 'react';
import { mount } from 'enzyme';
import configureStore from '../../state';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';
import FundraiserView, { mapStateToProps, mapDispatchToProps } from './FundraiserView';

describe('Initial rendering (#componentWillMount)', function () {
  it.skip('skips the first step when initialized with a default amount', () => {});
});

describe('Donation Amount Tab', function () {
  // This is how you would test a connected component
  beforeEach(() => {
    const store = configureStore();
    this.wrapper = mount(
      <Provider store={store}>
        <IntlProvider locale="en">
          <FundraiserView />
        </IntlProvider>
      </Provider>
    );
  });

  // rendering
  it.skip('always shows a list of donation amounts', () => {});
  it.skip('formats the donation amounts with the current currency', () => {});
  it.skip('does not have a "Proceed" button by default', () => {});
  it.skip('shows a "Proceed" button when the custom amount input is used', () => {});
  it.skip('allows us to change the currency with a toggler', () => {});


  describe('Initial state', () => {
    it.skip('has a default list of donation bands', () => {});
    it.skip('defaults to a currency', () => {});
  });

  describe('UI interactions:', () => {
    // selecting amounts
    it.skip('updates the selected amount when we click on a DonationBand button', () => {});
    it.skip('updates the selected amount when we use the custom input box', () => {});

    // changing the currency
    it.skip('reveals a currency dropdown when we click on the "Change currency" link', () => {});
    it.skip('changes the currency when we select a currency from the dropdown', () => {});
    it.skip('updates the DonationBand buttons to match the selected currency format', () => {});

    // transitioning
    it.skip('transitions to the next step when we select an amount', () => {});
  });
});

describe('mapStateToProps', function () {
  let stateFromProps: Object = {};
  beforeEach(() => stateFromProps = mapStateToProps(configureStore().getState()));

  it('returns member from state', () => {
    expect(stateFromProps.member).toBe(null);
  });

  it('returns the list of currencies from state', () => {
    expect(stateFromProps.currencies.length).toBe(6);
  });

  it('returns donationBands from state', () => {
    expect(stateFromProps.donationBands.length).toBe(5);
  });

  // this would actually go in fundraiser state
  it('returns currently selected donation amount', () => {
    expect(stateFromProps.donationAmount).toBe(null);
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
