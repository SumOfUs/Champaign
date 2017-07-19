// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import { asYouType, format, parse, isValidNumber } from 'libphonenumber-js';
import { get, findIndex } from 'lodash';
import { FormattedMessage } from 'react-intl';
import countryCodes from './country-codes.json';
import SweetInput from '../SweetInput/SweetInput';

import './SweetPhoneInput.scss';

type Props = {
  value: string,
  onChange: (number: string) => void,
  defaultCountry?: string,
  title?: any,
};

type State = {
  defaultCountry: string,
  countryCode: string,
  phoneNumber: string,
  countryCodeError?: any,
};

export default class SweetPhoneInput extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);
    const defaultCountry = get(
      window.champaign.personalization,
      'location.country'
    );
    this.state = {
      defaultCountry: props.defaultCountry || defaultCountry || 'US',
      countryCode: '',
      phoneNumber: '',
    };
  }

  defaultTitle() {
    return (
      <FormattedMessage
        id="call_tool.member_phone_number_title"
        defaultMessage="Enter your phone number"
      />
    );
  }
  onChange(number: string) {
    console.log('phone number changed:', number);
    this.props.onChange(number);
  }

  validateCountryCode(code: string) {
    if (!findIndex(countryCodes, { dialCode: code })) {
      // Translate invalid country code error?
      return 'country code is invalid';
    }
  }

  onPhoneNumberChange = (phoneNumber: string) => {
    const number = format(
      parse(`+${this.state.countryCode}${phoneNumber}`),
      'International_plaintext'
    );
    console.log('asYouType:', new asYouType().input(phoneNumber));
    console.log('parse:', number);
    console.log('isValidNumber:', isValidNumber(number));
    // FIXME: ^ are any of these methods useful? see https://github.com/catamphetamine/libphonenumber-js
    this.setState(prevState => ({ ...prevState, phoneNumber }));
  };

  onCountryCodeChange = (countryCode: string) => {
    console.log('country code changed:', countryCode);
    this.setState(prevState => ({
      // FIXME: i don't think replace('+', '') everywhere should be a thing
      countryCode: countryCode.replace('+', ''),
      // FIXME: ditto .replace(...)
      countryCodeError: this.validateCountryCode(countryCode.replace('+', '')),
    }));
  };

  render() {
    const className = classnames({
      SweetPhoneInput: true,
    });

    return (
      <div className="SweetPhoneInputContainer">
        <p className="SweetPhoneInput__Title">
          {this.props.title || this.defaultTitle()}
        </p>
        <div className={className}>
          <SweetInput
            className="SweetPhoneInput__CountryCode"
            value={this.state.countryCode}
            type="tel"
            label="Code"
            required
            errorMessage={this.state.countryCodeError}
            onChange={this.onCountryCodeChange}
          />
          <SweetInput
            type="tel"
            className="SweetPhoneInput__PhoneNumber"
            value={this.state.phoneNumber}
            label="Phone number"
            required
            errorMessage={this.state.countryCodeError}
            onChange={this.onPhoneNumberChange}
          />
        </div>
      </div>
    );
  }
}
