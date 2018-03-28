// @flow
import React, { Component } from 'react';
import { indexOf } from 'lodash';
import SweetSelect from '../SweetSelect/SweetSelect';
import countriesEn from './countries/en.json';
import countriesDe from './countries/de.json';
import countriesEs from './countries/es.json';
import countriesFr from './countries/fr.json';
import { injectIntl, intlShape } from 'react-intl';
import type { Element } from 'react';

export type Country = { value: string, label: string };
export const countries = countriesEn;

type FilterCountry = string;

type Props = {
  name?: string,
  value?: string,
  onChange?: (value: any) => void,
  options?: Country[],
  label?: Element<any> | string,
  disabled?: boolean,
  multiple?: boolean,
  intl: intlShape,
  className?: string,
  clearable?: boolean,
  filter?: FilterCountry[],
};

const countriesByLocale = {
  en: countriesEn,
  es: countriesEs,
  de: countriesDe,
  fr: countriesFr,
};

export class SelectCountry extends Component {
  props: Props;
  focus() {
    if (!this.refs.select) return;
    this.refs.select.focus();
  }

  render() {
    const props = this.props;
    let countries = countriesByLocale[props.intl.locale];

    countries = Object.keys(countries)
      .map(c => {
        return { value: c, label: countries[c] };
      })
      .sort((a, b) => {
        let countryA = a.label.toUpperCase();
        let countryB = b.label.toUpperCase();
        if (countryA < countryB) return -1;
        if (countryA > countryB) return 1;

        return 0;
      });

    if (props.filter && props.filter.length) {
      countries = countries.filter(c => {
        return indexOf(props.filter, c.value) > -1;
      });
    }

    return (
      <SweetSelect
        {...props}
        ref="select"
        options={props.options || countries}
      />
    );
  }
}

export default injectIntl(SelectCountry, { withRef: true });
