// @flow
import _ from 'lodash';
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import DonationBands from '../DonationBands/DonationBands';
import Button from '../Button/Button';
import $ from '../../util/PubSub';
import CurrencyAmount from '../../components/CurrencyAmount';

export type OwnProps = {
  donationAmount?: number;
  donationBands: {[id:string]: number[]};
  donationFeaturedAmount?: number;
  currency: string;
  nextStepTitle?: string;
  selectAmount: (amount: ?number) => void;
  changeCurrency: (currency: string) => void;
  proceed: () => void;
};

export type OwnState = {
  customAmount: ?number;
  currencyDropdownVisible: boolean;
};

export default class AmountSelection extends Component {
  props: OwnProps;
  state: OwnState;

  static title(amount: ?number, currency: string): any {
    if (amount == null) {
      return <FormattedMessage id="fundraiser.amount" defaultMessage="AMOUNT" />;
    }
    return <CurrencyAmount amount={amount} currency={currency} />;

  }

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      customAmount: null,
      currencyDropdownVisible: false,
    };
  }

  componentDidUpdate() {
    $.publish('sidebar:height_change');
  }

  toggleCurrencyDropdown() {
    this.setState({
      currencyDropdownVisible: !this.state.currencyDropdownVisible,
    });
  }

  onSelectCurrency(currency: string) {
    this.props.changeCurrency(currency);
  }

  selectFeaturedAmount() {
    if (this.props.donationFeaturedAmount) {
      this.props.selectAmount(this.props.donationFeaturedAmount);
      this.props.proceed();
    }
  }

  proceed() {
    if (!this.props.donationAmount && this.props.donationFeaturedAmount) {
      this.props.selectAmount(this.props.donationFeaturedAmount);
    }

    this.props.proceed();
  }

  render() {
    return (
      <div className="AmountSelection-container section">
        <DonationBands
          ref="donationBands"
          amounts={this.props.donationBands[this.props.currency]}
          currency={this.props.currency}
          proceed={this.props.proceed}
          featuredAmount={this.props.donationFeaturedAmount}
          selectAmount={this.props.selectAmount}
        />
        <p>
          <FormattedMessage
            id="fundraiser.currency_in"
            defaultMessage="Values are shown in {currency}."
            values={{ currency: this.props.currency }}
          />.&nbsp;
          <a onClick={this.toggleCurrencyDropdown.bind(this)} className="AmountSelection__currency-toggle">
            <FormattedMessage id="fundraiser.switch_currency" defaultMessage="Switch currency" />
          </a>
        </p>
        { this.state.currencyDropdownVisible &&
          <select value={this.props.currency} className="AmountSelection__currency-selector"
            onChange={e => this.onSelectCurrency(e.target.value)}>
             {_.keys(this.props.donationBands).map((currency) => {
               return <option key={currency} value={currency}>{currency}</option>;
             })}
          </select>
        }

        <Button
          className="btn AmountSelection__proceed-button"
          onClick={() => this.proceed()}
          disabled={!(this.props.donationAmount || this.props.donationFeaturedAmount)}>
          { this.props.nextStepTitle ?
            this.props.nextStepTitle :
            <FormattedMessage id="fundraiser.proceed_to_details" defaultMessage="Proceed to details" />
          }
        </Button>
      </div>
    );
  }
}
