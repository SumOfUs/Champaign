/* @flow */
import React, { Component } from 'react';
import { FormattedNumber } from 'react-intl';
import Button from '../Button/Button';
import './DonationBands.css';

const FORMATTED_NUMBER_DEFAULTS = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

type Props = {
  amounts: number[];
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
    if (value.match(/^(\d{1,10})$/) && parseFloat(value) <= MAX_CUSTOM_VALUE) {
      amount = parseFloat(value);
      this.setState({ customAmount: value });
    } else if (value === '') {
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
    const visible = !!value.length;
    if (this.props.toggleProceedButton) {
      this.props.toggleProceedButton(visible);
    }
  }

  renderButton(amount: number, i: number): Button {
    return (
      <Button key={i}
              className="DonationBands-button"
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
          className="DonationBands-input styled"
          placeholder="Other"
          pattern={/^[0-9]+ff$/}
          value={this.state.customAmount || ''}
          onFocus={(e) => this.onInputFocused(e.target.value)}
          onBlur={e => this.onInputBlurred(e.target.value)}
          onChange={({target}) => this.onInputUpdated(target.value)}/>
      </div>
    );
  }
}

export default DonationBands;
