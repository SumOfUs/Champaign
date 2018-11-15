// @flow
import React from 'react';
import {
  shallowWithIntl,
  mountWithIntl,
} from '../../../../spec/jest/intl-enzyme-test-helpers';
import AmountSelection from './AmountSelection';
import type { Props } from './AmountSelection';

const defaultProps: Props = {
  donationAmount: undefined,
  donationBands: {
    USD: [1, 2, 3, 4, 5],
    GBP: [6, 7, 8, 9, 10],
  },
  currency: 'USD',
  changeCurrency: jest.fn(),
  selectAmount: jest.fn(),
  proceed: jest.fn(),
};

it('renders', () => {
  const component = mountWithIntl(<AmountSelection {...defaultProps} />);
  expect(component.html()).toBeTruthy();
});

describe('Donation bands', () => {
  const component = mountWithIntl(<AmountSelection {...defaultProps} />);

  it('shows the donation band passed as an argument', () => {
    const firstButton = component
      .find('DonationBands')
      .find('Button')
      .first();
    const lastButton = component
      .find('DonationBands')
      .find('Button')
      .last();
    expect(firstButton.text()).toBe('$1');
    expect(lastButton.text()).toBe('$5');
  });

  it('calls `selectedAmount` with the selected amount when we click on a DonationBand button', () => {
    // select first amount ($1)
    component
      .find('DonationBands')
      .find('Button')
      .first()
      .simulate('click');
    expect(defaultProps.selectAmount).toBeCalledWith(1);

    // select last amount ($5)
    component
      .find('DonationBands')
      .find('Button')
      .last()
      .simulate('click');
    expect(defaultProps.selectAmount).toBeCalledWith(5);
  });
});

describe('Changing currency', () => {
  const component = mountWithIntl(<AmountSelection {...defaultProps} />);

  it('does not show the currency menu by default', () => {
    expect(component.find('.AmountSelection__currency-selector').length).toBe(
      0
    );
  });

  it('shows a "Switch currency" button', () => {
    expect(component.find('.AmountSelection__currency-toggle').length).toBe(1);
    expect(component.find('.AmountSelection__currency-toggle').text()).toBe(
      'Switch currency'
    );
  });

  it('"Switch currency" toggles the currency menu', () => {
    // show it
    component.find('.AmountSelection__currency-toggle').simulate('click');
    expect(component.find('.AmountSelection__currency-selector').length).toBe(
      1
    );

    // check contents
    const selector = component.find('.AmountSelection__currency-selector');
    expect(
      selector
        .find('option')
        .first()
        .prop('value')
    ).toBe('USD');
    expect(
      selector
        .find('option')
        .last()
        .prop('value')
    ).toBe('GBP');

    // hide it
    component.find('.AmountSelection__currency-toggle').simulate('click');
    expect(component.find('.AmountSelection__currency-selector').length).toBe(
      0
    );
  });

  it('updates the currency in the store when we select a currency', () => {
    component.find('.AmountSelection__currency-toggle').simulate('click');
    const selector = component.find('.AmountSelection__currency-selector');
    selector.simulate('change', { target: { value: 'GBP' } });
    expect(defaultProps.changeCurrency).toBeCalledWith('GBP');
  });
});

describe('Proceed button', () => {
  it('is rendered if there is a featured amount', () => {
    const component = shallowWithIntl(
      <AmountSelection {...defaultProps} donationFeaturedAmount={1} />
    );
    const button = component.find('Button.AmountSelection__proceed-button');
    expect(button.length).toBe(1);
    expect(button.prop('disabled')).toBe(false);
  });

  it('is enabled if there is a donation amount', () => {
    const component = shallowWithIntl(
      <AmountSelection {...defaultProps} donationAmount={1} />
    );
    const button = component.find('Button.AmountSelection__proceed-button');
    expect(button.length).toBe(1);
    expect(button.prop('disabled')).toBe(false);
  });

  it('is not rendered if there is no donation (or featured) amount', () => {
    const component = shallowWithIntl(<AmountSelection {...defaultProps} />);
    const button = component.find('Button.AmountSelection__proceed-button');
    expect(button.length).toBe(0);
  });
});
