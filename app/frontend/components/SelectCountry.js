// @flow
import React from 'react';
import SweetSelect from './SweetSelect/SweetSelect';
import countryData from 'country-data/data/countries.json';
import sortBy from 'lodash/sortBy';
import type { Element } from 'react';

export type Country = { value: string; label: string; };

type Props = {
  name: string;
  value?: string;
  onChange: (value: any) => void;
  options?: Country[];
  label?: Element<any> | string;
  disabled?: boolean;
  multiple?: boolean;
};

const countries = sortBy(countryData
  .filter(c => c.status === 'assigned')
  .filter(c => c.ioc !== '')
  .map(c => ({ value: c.alpha2, label: c.name })), 'label');

export default function SelectCountry(props: Props) {
  return (
    <SweetSelect
      {...props}
      options={props.options || countries}
    />
  );
}


