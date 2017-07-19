// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import { findKey } from 'lodash';
import { FormattedMessage } from 'react-intl';
import SweetInput from '../SweetInput/SweetInput';
import SweetSelect from '../SweetSelect/SweetSelect';
import countryCodes from './country-codes.json';

import './SweetPhoneInput.scss';

type Props = {
  value: string,
  onChange: (number: string) => void,
  defaultCountry?: string,
  countries?: string[],
  preferredCountries?: string[],
};

type State = {
  countryCode: string,
};

export default class SweetPhoneInput extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);
    this.state = {
      countryCode: countryCodes[props.defaultCountry || 'US'],
    };
  }

  onCountryCodeChange(countryCode: string) {
    this.setState({ countryCode });
  }
  onPhoneNumberChange(number: string) {
    this.props.onChange(`${this.state.countryCode}${number}`);
  }

  render() {
    const className = classnames({
      SweetPhoneInput: true,
    });

    const countries = [
      { value: 'CA', label: 'Canada' },
      { value: 'GB', label: 'United Kingdom' },
      { value: 'US', label: 'United States' },
    ];

    return (
      <div className={className}>
        <div className="SweetPhoneInput__CountryCode">
          <SweetSelect
            name="SweetPhoneInput__CountryCode"
            onChange={country => console.log('country:', country)}
            options={countries}
          />
        </div>
        <div className="SweetPhoneInput__PhoneNumber">
          <SweetInput
            type="tel"
            value={this.props.value}
            label={<FormattedMessage id="call_tool.form.phone_number" />}
            onChange={this.props.onChange}
          />
        </div>
      </div>
    );
  }
}
