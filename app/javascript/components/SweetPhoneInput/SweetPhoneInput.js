// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import {
  asYouType,
  format,
  getPhoneCode,
  parse,
  isValidNumber,
} from 'libphonenumber-js';
import { get, findIndex } from 'lodash';
import { FormattedMessage } from 'react-intl';
import onClickOutside from 'react-onclickoutside';
import countryCodes from './country-codes.json';
import SweetInput from '../SweetInput/SweetInput';
import SelectCountry from '../SelectCountry/SelectCountry';

import './SweetPhoneInput.scss';

type Props = {
  value: string,
  onChange: (number: string) => void,
  defaultCountryCode: string,
  title?: any,
  className?: string,
};

type State = {
  countryCode: string,
  phoneNumber: string,
  selectingCountry: boolean,
};

class SweetPhoneInput extends Component {
  props: Props;
  state: State;
  selectCountry: any;

  constructor(props: Props) {
    super(props);
    this.state = {
      countryCode: this.props.defaultCountryCode || this.defaultCountry(),
      phoneNumber: props.value || '',
      selectingCountry: false,
    };
  }

  defaultCountry(): string {
    return get(window, 'champaign.personalization.location.country', 'US');
  }

  componentWillReceiveProps(newProps) {
    const countryCode = newProps.defaultCountry || this.defaultCountry();
    this.setState(state => ({ ...state, countryCode }));
  }

  handleClickOutside(e: SyntheticEvent) {
    this.setState(state => ({ ...state, selectingCountry: false }));
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
    this.props.onChange(number);
  }

  validateCountryCode(code: string) {
    if (!findIndex(countryCodes, { dialCode: code })) {
      // Translate invalid country code error?
      return 'country code is invalid';
    }
  }

  onPhoneNumberChange = (phoneNumber: string) => {
    // First of all detect international format
    const type: string = phoneNumber[0] === '+' ? 'International' : 'National';
    const x = new asYouType(this.state.countryCode).input(phoneNumber);
    this.setState(prevState => ({ ...prevState, phoneNumber: x }));
    console.log(
      'format:',
      format(phoneNumber, this.state.countryCode, 'International')
    );
    this.props.onChange(
      format(phoneNumber, this.state.countryCode, 'International_plaintext')
    );
  };

  onCountryCodeChange = (countryCode: string) => {
    console.log('onCountryCodeChange:', countryCode);
    this.setState(
      state => ({
        ...state,
        countryCode,
        selectingCountry: false,
      }),
      () => {
        if (this.refs.phoneInput) {
          this.refs.phoneInput.focus();
        }
      }
    );
  };

  toggleSelectingCountry = () => {
    this.setState(
      state => ({
        ...state,
        selectingCountry: !state.selectingCountry,
      }),
      () => {
        if (this.state.selectingCountry) {
          this.refs.select.refs.wrappedInstance.focus();
        }
      }
    );
  };

  render() {
    const className = classnames(
      {
        SweetPhoneInput__root: true,
        'selecting-country': this.state.selectingCountry,
      },
      this.props.className
    );

    return (
      <div className={className}>
        <div className="SweetPhoneInput__title">
          {this.props.title || this.defaultTitle()}
        </div>
        <div className="SweetPhoneInput">
          <div
            className="SweetPhoneInput__flag-container"
            onClick={this.toggleSelectingCountry}
          >
            <div className="SweetPhoneInput__selected-code">
              + {getPhoneCode(this.state.countryCode)}
            </div>
            <i
              className="fa fa-chevron-down"
              style={{
                fontSize: '.7em',
                marginLeft: '5px',
                color: '#ccc',
              }}
            />
          </div>
          <div className="SweetPhoneInput__phone-number">
            <input
              ref="phoneInput"
              className="SweetPhoneInput__phone-number-input"
              type="tel"
              value={this.state.phoneNumber}
              onChange={e => this.onPhoneNumberChange(e.target.value)}
            />
          </div>
          <SelectCountry
            ref="select"
            className="SweetPhoneInput__select-country"
            clearable={false}
            label="Select your country..."
            value={this.state.countryCode}
            onChange={code => this.onCountryCodeChange(code)}
          />
        </div>
      </div>
    );
  }
}

export default onClickOutside(SweetPhoneInput);
