// @flow
import React from 'react';
import _ from 'lodash';
import SweetSelect from '../SweetSelect/SweetSelect';
import countriesEn from './countries/en.json';
import countriesDe from './countries/de.json';
import countriesEs from './countries/es.json';
import countriesFr from './countries/fr.json';
import {injectIntl, intlShape} from 'react-intl';
import type { Element } from 'react';

export type Country = { value: string; label: string; };

type FilterCountry = string;

type Props = {
  name?: string;
  value?: string;
  onChange?: (value: any) => void;
  options?: Country[];
  label?: Element<any> | string;
  disabled?: boolean;
  multiple?: boolean;
  intl: intlShape;
  filter?: FilterCountry[];
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

  if(props.filter && props.filter.length) {
    countries = countries.filter((c) => {
      return _.indexOf(props.filter, c.value) > -1;
    });
  }

  return (
    <SweetSelect
      {...props}
      options={props.options || countries}
    />
  );
};

export { SelectCountry };

export default injectIntl(SelectCountry);
