// @flow
import React, { Component } from 'react';
import { map, indexOf } from 'lodash';
import SweetSelect from '../SweetSelect/SweetSelect';
import countriesEn from './countries/en.json';
import countriesDe from './countries/de.json';
import countriesEs from './countries/es.json';
import countriesFr from './countries/fr.json';
import { injectIntl, intlShape } from 'react-intl';
import type { Element } from 'react';
import type { IntlShape } from 'react-intl';
import type { SelectOption } from 'react-select';

export const countries = countriesEn;

type FilterCountry = string;

type Props = {
  name?: string,
  value?: string,
  onChange?: (value: any) => void,
  options?: SelectOption[],
  label?: string,
  disabled?: boolean,
  multiple?: boolean,
  intl: IntlShape,
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

export class SelectCountry extends Component<Props> {
  focus() {
    if (!this.refs.select) return;
    this.refs.select.focus();
  }

  render() {
    const props = this.props;
    const locale = props.intl.locale;
    let countries = countriesByLocale[locale];

    countries = Object.keys(countries)
      .map(c => ({ value: c.toString(), label: countries[c].toString() }))
      .sort((a, b) => {
        if (typeof window.Intl.Collator === 'function') {
          return new window.Intl.Collator(locale).compare(a.label, b.label);
        }
        if (a.label.toString() > b.label.toString()) return 1;
        if (a.label.toString() < b.label.toString()) return -1;
        return 0;
      });

    if (props.filter && props.filter.length) {
      countries = countries.filter(c => {
        return indexOf(props.filter, c.value.toString()) > -1;
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
