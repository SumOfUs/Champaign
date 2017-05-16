/* @flow */
import React, { Component } from 'react';
import $ from 'jquery';
import { FormattedNumber, injectIntl } from 'react-intl';
import classnames from 'classnames';
import DonationBandButton from './DonationBandButton';
import './DonationBands.css';

import type { IntlShape } from 'react-intl';

const FORMATTED_NUMBER_DEFAULTS = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

type Props = {
  amounts: number[],
  currency: string,
  customAmount?: number,
  proceed: () => void,
  intl: IntlShape,
  selectAmount: (amount: ?number) => void,
  featuredAmount?: number,
};

export class DonationBands extends Component {
  props: Props;

  state: {
    customAmount: string,
  };

  constructor(props: Props) {
    super(props);

    let customAmount = '';
    if (props.customAmount) {
      customAmount = props.customAmount.toString();
    }

    this.state = {
      customAmount: customAmount,
    };
  }

  onButtonClicked(amount: number = 0) {
    this.setState({ customAmount: '' });
    this.props.selectAmount(amount);
    this.props.proceed();
  }

  onInputUpdated(value: string) {
    let amount = null;
    // \u00a3 is £, \u20ac is €
    const match = value.match(/^[$\u20ac\u00a3]*(\d{0,10})/);

    if (match && match[1].length) {
      amount = parseFloat(match[1]);
      this.setState({ customAmount: amount.toString() });
    } else if (value === '' || (match && match[1] === '')) {
      amount = null;
      this.setState({ customAmount: '' });
    } else {
      amount = parseFloat(this.state.customAmount);
    }

    if (this.props.selectAmount) {
      this.props.selectAmount(amount);
    }
  }

  customFieldDisplay() {
    const amountString = this.state.customAmount || '';
    if (amountString === '') return '';
    let currencySymbol = this.props.currency === 'GBP' ? '£' : '$';
    if (this.props.currency === 'EUR') currencySymbol = '€';
    return `${currencySymbol}${amountString}`;
  }

  render() {
    const { amounts } = this.props;
    return (
      <div className="DonationBands-container">
        {amounts.map((amount, i) =>
          <DonationBandButton
            key={i}
            amount={amount}
            featuredAmount={this.props.featuredAmount}
            currency={this.props.currency}
            onClick={() => this.onButtonClicked(amount)}
          />
        )}
        <input
          type="tel"
          ref="customAmount"
          id="DonationBands-custom-amount"
          className="DonationBands__input"
          placeholder={this.props.intl.formatMessage({
            id: 'fundraiser.other_amount',
          })}
          pattern={/^[0-9]+$/}
          value={this.customFieldDisplay()}
          onChange={(e: SyntheticInputEvent) =>
            this.onInputUpdated(e.target.value)}
        />
      </div>
    );
  }
}

export default injectIntl(DonationBands);
