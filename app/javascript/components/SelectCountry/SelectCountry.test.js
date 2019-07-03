import React from 'react';
import { shallow } from 'enzyme';
import { SelectCountry } from './SelectCountry';
import { IntlProvider } from 'react-intl';

const mockFn = jest.fn();
const intl = new IntlProvider({ locale: 'en' });
const component = shallow(
  <SelectCountry
    name="country"
    onChange={mockFn}
    intl={intl.props}
    label="Select yourself a country"
  />
);

it('renders a list of countries by default', () => {
  const select = component.find('SweetSelect');
  const countries: Country[] = select.props().options;
  expect(countries.length).toBeGreaterThan(100);
});

it('accepts a custom list of countries', () => {
  const list = [
    { label: 'United Kingdom', value: 'GB' },
    { label: 'United States', value: 'USA' },
  ];

  const wrapper = shallow(
    <SelectCountry
      name="countries"
      intl={intl.props}
      options={list}
      onChange={mockFn}
    />
  );
  const countries: Country[] = wrapper.find('SweetSelect').props().options;

  expect(countries.length).toEqual(2);
});

it('accepts a label', () => {
  expect(component.find('SweetSelect').props().label).toMatch(
    /Select yourself a country/
  );
});

it('accepts an onChange prop', () => {
  component.simulate('change', 'GB');
  expect(mockFn).toHaveBeenCalledWith('GB');
});

describe('localisation', () => {
  it('renders countries in German', () => {
    const intl = new IntlProvider({ locale: 'de' });
    const select = shallow(<SelectCountry intl={intl.props} />).find(
      'SweetSelect'
    );
    const countries: Country[] = select.props().options;
    expect(countries[0].label).toEqual('Afghanistan');
    expect(countries[2].label).toEqual('Åland');
    expect(countries[countries.length - 1].label).toEqual('Zypern');
  });
});
