// @flow
import React, { Component } from 'react';
import DonationBands from '../DonationBands/DonationBands';
import Button from '../Button/Button';

type OwnProps = {
  donationAmount: ?number;
  donationBands: ?number[];
  currency: string;
  currencies: string[];
  onSelectAmount: (amount: ?number) => void;
  onChangeCurrency: (currency: string) => void;
};

type OwnState = {
  customAmount: ?number;
  currencyDropdownVisible: boolean;
  proceedButtonVisible: boolean;
};

export default class AmountSelection extends Component {
  props: OwnProps;
  state: OwnState;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      customAmount: null,
      proceedButtonVisible: false,
      currencyDropdownVisible: false,
    };
  }

  onSelectAmount(amount: ?number) {
    this.props.onSelectAmount(amount);
  }

  onChangeCustomAmount(amount: ?number) {
    this.setState({ customAmount: amount });
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
    this.props.onChangeCurrency(currency);
  }

  onProceed() {
    console.log('proceeding to next step...');
  }

  render() {
    const { proceedButtonVisible } = this.state;
    return (
      <div className="AmountSelection-container section">
        <DonationBands
          ref="donationBands"
          amounts={this.props.donationBands}
          currency={this.props.currency}
          onSelectAmount={this.onSelectAmount.bind(this)}
          onChangeCustomAmount={this.onChangeCustomAmount.bind(this)}
          toggleProceedButton={this.toggleProceedButton.bind(this)}
        />
        <p>
          Values shown in {this.props.currency}, <a href="#" onClick={this.toggleCurrencyDropdown.bind(this)}>
          Change currency</a>.
        </p>
        {this.state.currencyDropdownVisible &&
          <select value={this.props.currency} onChange={e => this.onSelectCurrency(e.target.value)}>
            {this.props.currencies.map(c => <option key={c} value={c}>{c}</option>)}
          </select>
        }

        { proceedButtonVisible && (
          <Button className="btn" onClick={() => this.onProceed()} disabled={!this.props.donationAmount}>
            PROCEED TO DETAILS
          </Button>
        )}
      </div>
    );
  }
}
