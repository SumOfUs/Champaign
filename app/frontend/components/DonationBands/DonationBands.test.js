// @flow
import React from 'react';
import { mount } from 'enzyme';
import { IntlProvider } from 'react-intl';
import DonationBands from './DonationBands';

const amounts = [1, 2, 3, 4, 5];

const selectAmount = jest.fn();
const proceed = jest.fn();

const component = (
  <IntlProvider locale="en-CA">
    <DonationBands
      customAmount={10}
      amounts={amounts}
      currency="GBP"
      proceed={proceed}
      selectAmount={selectAmount}
    />
  </IntlProvider>
);

it('renders all amounts with the currency symbol', () => {
  const wrapper = mount(component);
  expect(wrapper.childAt(0).html()).toMatch(/£1/);
  expect(wrapper.childAt(1).html()).toMatch(/£2/);
  expect(wrapper.childAt(2).html()).toMatch(/£3/);
  expect(wrapper.childAt(3).html()).toMatch(/£4/);
  expect(wrapper.childAt(4).html()).toMatch(/£5/);
});

it('renders a custom input as the last element', () => {
  const wrapper = mount(component);
  expect(wrapper.childAt(5).containsMatchingElement(<input />)).toBeTruthy();
});

it('calls `selectAmount` when user clicks on an amount', () => {
  const wrapper = mount(component);

  selectAmount.mockClear();

  wrapper.childAt(0).simulate('click');
  expect(selectAmount).toHaveBeenCalledWith(1);

  selectAmount.mockClear();
});

it('calls `selectAmount` when user clicks on an amount', () => {
  const wrapper = mount(component);

  selectAmount.mockClear();

  wrapper.childAt(0).simulate('click');
  expect(selectAmount).toHaveBeenCalledWith(1);

  selectAmount.mockClear();
});

it('clears the input when the user clicks on a donation amount button', () => {
  const wrapper = mount(component);
  const input = wrapper.childAt(5);

  input.simulate('focus');
  input.simulate('change', { target: { value: '123' }});

  const inputEl = input.get(0);
  if (!(inputEl instanceof HTMLInputElement)) {
    throw new Error('Unexpected element type');
  }

  expect(inputEl.value).toBe('£123');
  wrapper.childAt(0).simulate('click');
  expect(inputEl.value).toBe('');
});
