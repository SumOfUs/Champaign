// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import { asYouType, format, parse, isValidNumber } from 'libphonenumber-js';
import { get, findIndex } from 'lodash';
import { FormattedMessage } from 'react-intl';
import onClickOutside from 'react-onclickoutside';
import countryCodes from './country-codes.json';
import SweetInput from '../SweetInput/SweetInput';
import Flag from './Flag';
import SelectCountry from '../SelectCountry/SelectCountry';

import './SweetPhoneInput.scss';

type Props = {
  value: string,
  onChange: (number: string) => void,
  defaultCountry?: string,
  title?: any,
  className?: string,
};

type State = {
  defaultCountry: string,
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
      countryCode: this.props.defaultCountry || this.defaultCountry(),
      phoneNumber: props.value || '',
      selectingCountry: false,
    };
  }

  defaultCountry() {
    return get(window.champaign.personalization, 'location.country') || 'US';
  }

  componentWillReceiveProps(newProps) {
    this.setState({
      countryCode: newProps.defaultCountry || this.defaultCountry(),
    });
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
    // First of all detect international format
    const format: string =
      phoneNumber[0] === '+' ? 'International' : 'National';
    console.log('format:', format);
    // if format is international

    /*
    const number = format(
      parse(`+${this.state.countryCode}${phoneNumber}`),
      'International_plaintext'
    );
    console.log('asYouType:', new asYouType().input(phoneNumber));
    console.log('parse:', number);
    console.log('isValidNumber:', isValidNumber(number));
    // FIXME: ^ are any of these methods useful? see https://github.com/catamphetamine/libphonenumber-js

    */
    const x = new asYouType(this.state.countryCode).input(phoneNumber);
    this.setState(prevState => ({ ...prevState, phoneNumber: x }));
  };

  onCountryCodeChange = (countryCode: string) => {
    console.log('country code changed:', countryCode);
    this.setState(state => ({
      ...state,
      countryCode,
      selectingCountry: false,
    }));
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
            <div className="SweetPhoneInput__selected-flag">
              <Flag countryCode={this.state.countryCode} />
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
