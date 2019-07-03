import * as React from 'react';
import { FormattedMessage } from 'react-intl';
import DonationBands from '../DonationBands/DonationBands';
import Button from '../Button/Button';
import ee from '../../shared/pub_sub';
import Thermometer from '../Thermometer';

import CurrencyAmount from '../../components/CurrencyAmount';

export default class AmountSelection extends React.Component {
  static title(amount, currency) {
    if (amount == null) {
      return (
        <FormattedMessage id="fundraiser.amount" defaultMessage="AMOUNT" />
      );
    }
    return <CurrencyAmount amount={amount} currency={currency} />;
  }

  constructor(props) {
    super(props);

    this.state = {
      customAmount: null,
      currencyDropdVisible: false,
    };
  }

  componentDidUpdate() {
    ee.emit('sidebar:height_change');
  }

  toggleCurrencyDropd() {
    this.setState({
      currencyDropdVisible: !this.state.currencyDropdVisible,
    });
  }

  onSelectCurrency(currency) {
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
        <Thermometer />
        <DonationBands
          ref="donationBands"
          amounts={this.props.donationBands[this.props.currency]}
          currency={this.props.currency}
          proceed={this.props.proceed}
          featuredAmount={this.props.donationFeaturedAmount}
          selectAmount={this.props.selectAmount}
          selectCustomAmount={this.props.selectCustomAmount}
        />
        <p>
          <FormattedMessage
            id="fundraiser.currency_in"
            defaultMessage="Values shown in {currency}."
            values={{ currency: this.props.currency }}
          />
          .&nbsp;
          <a
            onClick={this.toggleCurrencyDropd.bind(this)}
            className="AmountSelection__currency-toggle"
          >
            <FormattedMessage
              id="fundraiser.switch_currency"
              defaultMessage="Switch currency"
            />
          </a>
        </p>
        {this.state.currencyDropdVisible && (
          <select
            value={this.props.currency}
            className="AmountSelection__currency-selector"
            onChange={e => this.onSelectCurrency(e.currentTarget.value)}
          >
            {Object.keys(this.props.donationBands).map(currency => {
              return (
                <option key={currency} value={currency}>
                  {currency}
                </option>
              );
            })}
          </select>
        )}

        {(this.props.donationAmount || this.props.donationFeaturedAmount) && (
          <Button
            className="btn AmountSelection__proceed-button"
            onClick={() => this.proceed()}
            disabled={
              !(this.props.donationAmount || this.props.donationFeaturedAmount)
            }
          >
            {this.props.nextStepTitle ? (
              this.props.nextStepTitle
            ) : (
              <FormattedMessage
                id="fundraiser.proceed_to_details"
                defaultMessage="Proceed to details"
              />
            )}
          </Button>
        )}
      </div>
    );
  }
}
