/* @flow */
import React, { Component } from 'react';
import { injectIntl } from 'react-intl';
import Button from '../Button/Button';
import './DonationBands.css';

type Props = {
  customAmount: ?number;
  amounts: number[];
  currency: string;
  onSelectAmount?: (amount: ?number) => void;
  onChangeCustomAmount?: (amount: ?number) => void;
  toggleProceedButton?: (visible: boolean) => void;
  intl: any;
};

const MAX_CUSTOM_VALUE = 100000; // 100k?

export class DonationBands extends Component {
  props: Props;

  state: {
    customAmount: string;
  };

  constructor(props: Props) {
    super(props);

    const { customAmount } = props;
    this.state = {
      customAmount: customAmount? customAmount.toString() : '',
    };
  }

  onButtonClicked(amount: number = 0) {
    this.setState({ customAmount: '' })
    this.onInputBlurred('');
    if (typeof this.props.onSelectAmount === 'function') {
      this.props.onSelectAmount(amount);
      console.log('onButtonClicked');
    }
  }

  onInputUpdated(value: string) {
    let amount = null;
    if (value.match(/^(\d{1,10})$/) && parseFloat(value) <= MAX_CUSTOM_VALUE) {
      amount = parseFloat(value);
      this.setState({ customAmount: value });
    } else if (value === '') {
      this.setState({ customAmount: '' });
    }

    if (this.props.onChangeCustomAmount) {
      this.props.onChangeCustomAmount(amount);
    }
  }

  onInputFocused(value: string) {
    if (this.props.toggleProceedButton) {
      this.props.toggleProceedButton(true);
    }
  }

  onInputBlurred(value: string) {
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
        {this.props.intl.formatNumber(amount, {
          style: 'currency',
          currency: this.props.currency,
          minimumFractionDigits: 0,
          maximumFractionDigits: 0
       })}
      </Button>
    );
  }

  render() {
    const { amounts } = this.props;
    return (
      <div className="DonationBands-container">
        {amounts.map((amount, i) => this.renderButton(amount, i))}
        <input
          ref="customAmount"
          id="DonationBands-custom-amount"
          className="DonationBands-input"
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

export default injectIntl(DonationBands);
