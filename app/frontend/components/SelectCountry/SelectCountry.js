// @flow
import React from 'react';
import SweetSelect from '../SweetSelect/SweetSelect';
import countriesEn from './countries/en.json';
import countriesDe from './countries/de.json';
import countriesEs from './countries/es.json';
import countriesFr from './countries/fr.json';
import {injectIntl, intlShape} from 'react-intl';
import type { Element } from 'react';

export type Country = { value: string; label: string; };

type Props = {
  name?: string;
  value?: string;
  onChange?: (value: any) => void;
  options?: Country[];
  label?: Element<any> | string;
  disabled?: boolean;
  multiple?: boolean;
  intl: intlShape;
};

const countriesByLocale = {
  en: countriesEn,
  es: countriesEs,
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

export { SelectCountry };

export default injectIntl(SelectCountry);
