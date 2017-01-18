// @flow
import React from 'react';
import SweetSelect from './SweetSelect/SweetSelect';
import countryData from 'country-data/data/countries.json';
import countriesEn from './../locales/countries/en.json';
import countriesDe from './../locales/countries/de.json';
import countriesFr from './../locales/countries/fr.json';
import {injectIntl, intlShape} from 'react-intl';
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
  intl: intlShape;
};

const countriesByLocale = {
  en: countriesEn,
  de: countriesDe,
  fr: countriesFr,
};

const SelectCountry = (props: Props) => {
  let countries = countriesByLocale[props.intl.locale];

  countries = Object.keys(countries).map((c) => {
    return {value: c, label: countries[c]};
  });

  return (
    <SweetSelect
      {...props}
      options={props.options || countries}
    />
  );
};

export default injectIntl(SelectCountry);
