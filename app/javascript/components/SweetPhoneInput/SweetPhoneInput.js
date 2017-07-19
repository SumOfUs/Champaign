// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import { get, findKey } from 'lodash';
import { FormattedMessage } from 'react-intl';
import ReactPhoneInput from 'react-phone-input';
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
  defaultCountry: string,
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
    };
  }

  onChange(number: string) {
    console.log('phone number changed:', number);
    this.props.onChange(number);
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
      <div>
        <p style={{ textAlign: 'center', margin: '1em' }}>
          Please put in your number
        </p>
        <div className={className}>
          <ReactPhoneInput
            defaultCountry={this.state.defaultCountry.toLowerCase()}
            onlyCountries={['us', 'gb', 'ca', 'de']}
            onChange={(number: string) => this.onChange(number)}
          />
        </div>
      </div>
    );
  }
}
