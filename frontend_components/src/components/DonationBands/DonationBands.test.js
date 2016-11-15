// @flow
import React from 'react';
import { mount, shallow } from 'enzyme';
import { IntlProvider } from 'react-intl';
import DonationBands from './DonationBands';
import Button from '../Button/Button';
import configureStore from '../../state';

const amounts = [1, 2, 3, 4, 5];
const onSelectAmount = jest.fn();
const component = (
  <IntlProvider locale="en-CA">
    <DonationBands
      customAmount={10}
      amounts={amounts}
      currency="GBP"
      onSelectAmount={onSelectAmount}
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

it('calls `onSelectAmount` when user clicks on an amount', () => {
  const wrapper = mount(component);

  onSelectAmount.mockClear();

  wrapper.childAt(0).simulate('click');
  expect(onSelectAmount).toHaveBeenCalledWith(1);

  onSelectAmount.mockClear();
});

it('calls `onSelectAmount` when user clicks on an amount', () => {
  const wrapper = mount(component);

  onSelectAmount.mockClear();

  wrapper.childAt(0).simulate('click');
  expect(onSelectAmount).toHaveBeenCalledWith(1);

  onSelectAmount.mockClear();
});

it('clears the input when the user clicks on a donation amount button', () => {
  const wrapper = mount(component);
  const input = wrapper.childAt(5);
  console.log(wrapper.html());
});
