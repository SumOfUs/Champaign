// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import { AsYouType, format, getPhoneCode } from 'libphonenumber-js';
import { get, findIndex } from 'lodash';
import { FormattedMessage } from 'react-intl';
import onClickOutside from 'react-onclickoutside';
import countryCodes from './country-codes.json';
import SweetInput from '../SweetInput/SweetInput';
import SelectCountry from '../SelectCountry/SelectCountry';

import './SweetPhoneInput.scss';

import type { Errors } from '../../plugins/call_tool/CallToolView';

type Props = {
  value: string,
  onChange: (number: string) => void,
  title?: any,
  className?: string,
  errors: Errors,
  defaultCountryCode?: string,
  restrictedCountryCode?: string,
};

type State = {
  countryCode?: string,
  phoneNumber: string,
  selectingCountry: boolean,
};

class SweetPhoneInput extends Component<Props, State> {
  selectCountry: any;

  constructor(props: Props) {
    super(props);
    this.state = {
      countryCode: undefined,
      phoneNumber: props.value || '',
      selectingCountry: false,
    };
  }

  getCountryCode() {
    if (!this.state) {
      return this.props.defaultCountryCode || this.defaultCountry();
    }

    return (
      this.state.countryCode ||
      this.props.defaultCountryCode ||
      this.defaultCountry()
    );
  }

  defaultCountry(): string {
    return get(window, 'champaign.personalization.location.country', 'US');
  }

  handleClickOutside(e: SyntheticEvent<*>) {
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

  onPhoneNumberChange = (value: string = '') => {
    this.setState(prevState => {
      const diff = value.replace(prevState.phoneNumber, '');
      const newPhoneNumber = new AsYouType(this.getCountryCode()).input(value);
      return {
        ...prevState,
        // if the diff is non-numeric, we didn't change a number so
        // we pick the unformatted value, otherwise pick the formatted value.
        phoneNumber: diff.match(/\D/) ? value : newPhoneNumber,
      };
    });
    this.props.onChange(format(value, this.getCountryCode(), 'International'));
  };

  onCountryCodeChange = (countryCode: string) => {
    if (!countryCode) return;

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
    if (this.props.restrictedCountryCode) return;

    this.setState(
      state => ({
        ...state,
        selectingCountry: !state.selectingCountry,
      }),
      () => {
        if (this.state.selectingCountry) {
          this.refs.select.props.onChange();
        }
      }
    );
  };

  render() {
    const { restrictedCountryCode } = this.props;
    const className = classnames(
      {
        SweetPhoneInput__root: true,
        'selecting-country': this.state.selectingCountry,
        'has-error': this.props.errors.memberPhoneNumber,
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
              + {getPhoneCode(this.getCountryCode())}
            </div>

            {!restrictedCountryCode && (
              <i
                className="fa fa-chevron-down"
                style={{
                  fontSize: '.7em',
                  marginLeft: '5px',
                  color: '#ccc',
                }}
              />
            )}
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
            value={this.getCountryCode()}
            filter={restrictedCountryCode ? [restrictedCountryCode] : undefined}
            onChange={code => this.onCountryCodeChange(code)}
          />
        </div>
        {this.props.errors.memberPhoneNumber !== undefined && (
          <div className="base-errors">
            {this.props.errors.memberPhoneNumber}
          </div>
        )}
      </div>
    );
  }
}

export default onClickOutside(SweetPhoneInput);
