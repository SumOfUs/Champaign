// @flow
import React from 'react';
import { mountWithIntl } from '../../../../spec/jest/intl-enzyme-test-helpers';
import toJson from 'enzyme-to-json';
import DonationBands from './DonationBands';

const amounts = [1, 2, 3, 4, 5];

const selectAmount = jest.fn();
const proceed = jest.fn();

const component = (
  <DonationBands
    customAmount={10}
    amounts={amounts}
    currency="GBP"
    proceed={proceed}
    selectAmount={selectAmount}
  />
);

it('renders correctly', () => {
  const wrapper = mountWithIntl(component).find('DonationBands');
  expect(toJson(wrapper)).toMatchSnapshot();
});

it('renders all amounts with the currency symbol', () => {
  const wrapper = mountWithIntl(component).find('DonationBands');
  expect(toJson(wrapper)).toMatchSnapshot();
});

it('renders a custom input as the last element', () => {
  const wrapper = mountWithIntl(component).find('DonationBands');
  expect(wrapper.find('#DonationBands-custom-amount')).toBeTruthy();
});

it('calls `selectAmount` when user clicks on an amount', () => {
  selectAmount.mockClear();
  const wrapper = mountWithIntl(component).find('DonationBands');
  wrapper
    .find('DonationBandButton')
    .first()
    .simulate('click');
  expect(selectAmount).toHaveBeenCalledWith(1);
  selectAmount.mockClear();
});

it('clears the input when the user clicks on a donation amount button', () => {
  // Mainly testing that the selectAmount callback is being called since
  // the value is passed down via props
  const wrapper = mountWithIntl(component);
  const input = wrapper.find('#DonationBands-custom-amount');
  input.simulate('focus');
  input.getDOMNode().value = '123';
  input.simulate('change');
  expect(selectAmount).toHaveBeenCalledWith(123);
  wrapper
    .find('DonationBandButton')
    .first()
    .simulate('click');
  expect(selectAmount).toHaveBeenCalledWith(1);
});
