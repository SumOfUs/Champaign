// @flow
import _ from 'lodash';
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import DonationBands from '../DonationBands/DonationBands';
import Button from '../Button/Button';
import CurrencyAmount from '../../components/CurrencyAmount';
import type { Element } from 'react';

type OwnProps = {
  donationAmount: ?number;
  donationBands: {[id:string]: number[]};
  donationFeaturedAmount?: number;
  currency: string;
  nextStepTitle: string;
  selectAmount: (amount: ?number) => void;
  changeCurrency: (currency: string) => void;
  proceed: () => void;
};

type OwnState = {
  customAmount: ?number;
  currencyDropdownVisible: boolean;
  proceedButtonVisible: boolean;
};

export default class AmountSelection extends Component {
  props: OwnProps;
  state: OwnState;

  static title(amount: ?number, currency: string): string | Element<any> {
    if (amount == null) {
      return <FormattedMessage id="fundraiser.amount" defaultMessage="AMOUNT" />;
    }
    return <CurrencyAmount amount={amount} currency={currency} />;

  }

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      customAmount: null,
      proceedButtonVisible: false,
      currencyDropdownVisible: false,
    };
  }

  selectAmount(amount: ?number) {
    this.props.selectAmount(amount);
  }

  toggleCurrencyDropdown() {
    this.setState({
      currencyDropdownVisible: !this.state.currencyDropdownVisible,
    });
  }

  toggleProceedButton(visible: boolean) {
    this.setState({ proceedButtonVisible: visible });
  }

  onSelectCurrency(currency: string) {
    this.props.changeCurrency(currency);
  }

  render() {
    const { proceedButtonVisible } = this.state;
    return (
      <div className="AmountSelection-container section">
        <DonationBands
          ref="donationBands"
          amounts={this.props.donationBands[this.props.currency]}
          currency={this.props.currency}
          proceed={this.props.proceed}
          featuredAmount={this.props.donationFeaturedAmount}
          selectAmount={this.selectAmount.bind(this)}
          toggleProceedButton={this.toggleProceedButton.bind(this)}
        />
        <p>
          <FormattedMessage
            id="fundraiser.currency_in"
            defaultMessage="Values are shown in {currency}."
            values={{ currency: this.props.currency }}
          />.&nbsp;
          <a onClick={this.toggleCurrencyDropdown.bind(this)}>
            <FormattedMessage id="fundraiser.switch_currency" defaultMessage="Switch currency" />
          </a>
        </p>
        {this.state.currencyDropdownVisible &&
          <select value={this.props.currency} className="AmountSelection__currency-selector"
            onChange={e => this.onSelectCurrency(e.target.value)}>
             {_.keys(this.props.donationBands).map((currency) => {
               return <option key={currency} value={currency}>{currency}</option>;
             })}
          </select>
        }

        { proceedButtonVisible && (
          <Button className="btn AmountSelection__proceed-button" onClick={() => this.props.proceed()} disabled={!this.props.donationAmount}>
            {this.props.nextStepTitle}
          </Button>
        )}
      </div>
    );
  }
}
