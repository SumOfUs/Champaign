// @flow
import React from 'react';
import { shallow } from 'enzyme';
import SelectCountry from './SelectCountry';
import type { Country } from './SelectCountry';

const mockFn = jest.fn();

const component = shallow(
  <SelectCountry name="country" onChange={mockFn} placeholder="Select a country" />
);

it('renders no problem', () => {
  expect(component.text()).toEqual('<Select />');
});

it('renders a list of countries by default', () => {
  const select = component.find('Select');
  const countries: Country[] = select.props().options;
  expect(countries.length).toBeGreaterThan(100);
});

it('accepts a custom list of countries', () => {
  const list = [
    { label: 'United Kingdom', value: 'GB' },
    { label: 'United States', value: 'USA' },
  ];
  const wrapper = shallow(<SelectCountry name="countries" options={list} onChange={mockFn} />);
  const countries: Country[] = wrapper.find('Select').props().options;

  expect(countries.length).toEqual(2);
});

it('accepts a placeholder', () => {
});

it('accepts an onChange prop', () => {
  component.simulate('change', 'GB');
  expect(mockFn).toHaveBeenCalledWith('GB');
});
