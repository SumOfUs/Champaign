/*  */
import React, { Component } from 'react';

import { FormattedNumber, injectIntl } from 'react-intl';
import classnames from 'classnames';
import DonationBandButton from './DonationBandButton';
import './DonationBands.css';

const FORMATTED_NUMBER_DEFAULTS = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

export class DonationBands extends Component {
  constructor(props) {
    super(props);

    this.state = {
      customAmount: props.customAmount,
    };
  }

  onButtonClicked(amount = 0) {
    this.setState({ customAmount: undefined });
    this.props.selectAmount(amount);
    this.props.proceed();
  }

  onInputUpdated(value) {
    // Remove non-digit characters before parsing
    const number = value.replace(/\D/g, '');
    const amount = number ? parseFloat(number) : undefined;
    this.setState({ customAmount: amount });
    if (this.props.selectCustomAmount) {
      this.props.selectCustomAmount(amount);
    } else {
      this.props.selectAmount(amount);
    }
  }

  customFieldDisplay() {
    if (!this.state.customAmount) return '';
    return this.props.intl.formatNumber(this.state.customAmount, {
      currency: this.props.currency,
      style: 'currency',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    });
  }

  render() {
    const { amounts } = this.props;
    return (
      <div className="DonationBands-container">
        {amounts.map((amount, i) => (
          <DonationBandButton
            key={i}
            amount={amount}
            featuredAmount={this.props.featuredAmount}
            currency={this.props.currency}
            onClick={() => this.onButtonClicked(amount)}
          />
        ))}
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
          onChange={e => this.onInputUpdated(e.currentTarget.value)}
        />
      </div>
    );
  }
}

export default injectIntl(DonationBands);
