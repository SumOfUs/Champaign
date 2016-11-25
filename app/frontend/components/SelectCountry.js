// @flow
import React from 'react';
import Select from 'react-select';
import countryData from 'country-data/data/countries.json';
import sortBy from 'lodash/sortBy';

export type Country = { value: string; label: string; };

type Props = {
  name: string;
  value?: string;
  onChange: (value: any) => void;
  options?: Country[];
  placeholder?: string | React$Element<any>;
  disabled?: boolean;
  multiple?: boolean;
};

const countries = sortBy(countryData
  .filter(c => c.status === 'assigned')
  .filter(c => c.ioc !== '')
  .map(c => ({ value: c.alpha2, label: c.name })), 'label');

export default function SelectCountry(props: Props) {
  return (
    <Select
      {...props}
      options={props.options || countries}
      onChange={item => props.onChange && props.onChange(item.value)}
    />
  );
}


