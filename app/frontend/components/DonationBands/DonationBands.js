/* @flow */
import React, { Component } from 'react';
import { FormattedNumber } from 'react-intl';
import classnames from 'classnames';
import Button from '../Button/Button';
import './DonationBands.css';

const FORMATTED_NUMBER_DEFAULTS = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

type Props = {
  amounts: number[];
  featuredAmount?: number;
  currency: string;
  customAmount?: number;
  proceed: () => void;
  selectAmount: (amount: ?number) => void;
  toggleProceedButton?: (visible: boolean) => void;
};

const MAX_CUSTOM_VALUE = 10000000; // 10 million?

export class DonationBands extends Component {
  props: Props;

  state: {
    customAmount: string;
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
    const match = value.match(/^[\$\u20ac\u00a3]*(\d{0,10})/);

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

  onInputFocused(value: string) {
    if (this.props.toggleProceedButton) {
      this.props.toggleProceedButton(true);
    }
  }

  onInputBlurred(value?: string = '') {
    const visible = !!value.match(/\d+/);
    if (this.props.toggleProceedButton) {
      this.props.toggleProceedButton(visible);
    }
  }

  customFieldDisplay() {
    let amountString = this.state.customAmount || '';
    if (amountString === '') return '';
    let currencySymbol = this.props.currency == 'GBP' ? '£' : '$';
    if (this.props.currency == 'EUR') currencySymbol = '€';
    return `${currencySymbol}${amountString}`;
  }

  renderButton(amount: number, index: number): Button {
    const className = classnames({
      'DonationBands-button': true,
      'DonationBands-button--highlight': (this.props.featuredAmount === amount)
    });

    return (
      <Button key={index}
              className={className}
              onClick={() => this.onButtonClicked(amount)}>
        <FormattedNumber {...FORMATTED_NUMBER_DEFAULTS} currency={this.props.currency} value={amount} />
      </Button>
    );
  }

  render() {
    const { amounts } = this.props;
    return (
      <div className="DonationBands-container">
        {amounts.map((amount, i) => this.renderButton(amount, i))}
        <input
          type="tel"
          ref="customAmount"
          id="DonationBands-custom-amount"
          className="DonationBands-input styled fundraiser-bar__custom-field"
          placeholder="Other"
          pattern={/^[0-9]+ff$/}
          value={this.customFieldDisplay()}
          onFocus={(e) => this.onInputFocused(e.target.value)}
          onBlur={e => this.onInputBlurred(e.target.value)}
          onChange={({target}) => this.onInputUpdated(target.value)}/>
      </div>
    );
  }
}

export default DonationBands;
