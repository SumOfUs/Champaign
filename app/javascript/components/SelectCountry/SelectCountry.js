// @flow
import React, { Component } from 'react';
import { indexOf } from 'lodash';
import isMobile from 'ismobilejs';
import SweetSelect from '../SweetSelect/SweetSelect';
import SweetHTMLSelect from '../SweetSelect/SweetHTMLSelect';
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

  render() {
    const props = this.props;
    let countries = countriesByLocale[props.intl.locale];

    countries = Object.keys(countries).map(c => {
      return { value: c, label: countries[c] };
    });

    if (props.filter && props.filter.length) {
      countries = countries.filter(c => {
        return indexOf(props.filter, c.value) > -1;
      });
    }

    if (isMobile.apple.phone) {
      return (
        <SweetHTMLSelect
          onChange={props.onChange}
          value={props.value}
          options={props.options || countries}
          placeholder="Country"
        />
      );
    }

    return (
      <SweetSelect
        {...props}
        options={props.options || countries}
        clearable={props.clearable || false}
      />
    );
  }
}

export default injectIntl(SelectCountry, { withRef: true });
