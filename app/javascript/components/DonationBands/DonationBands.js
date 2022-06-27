/*  */
import React, { Component } from 'react';

import { injectIntl } from 'react-intl';
import DonationBandButton from './DonationBandButton';
import './DonationBands.css';

export class DonationBands extends Component {
  constructor(props) {
    super(props);

    this.state = {
      customAmount: props.customAmount,
    };
  }

  onButtonClicked(e, amount = 0) {
    e.preventDefault();
    this.props.setSelectedAmountButton(e.target.name);
    this.setState({ customAmount: undefined });
    this.props.selectAmount(amount);
    this.props.proceed();
  }

  onInputUpdated(value) {
    // Remove non-digit characters before parsing
    const number = value.replace(/\D/g, '');
    const amount = number ? parseFloat(number) : undefined;
    this.setState({ customAmount: amount });
    this.props.setIsCustomAmount(true, amount);
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
            name={i + 1}
            amount={amount}
            featuredAmount={this.props.featuredAmount}
            currency={this.props.currency}
            onClick={event => this.onButtonClicked(event, amount)}
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
