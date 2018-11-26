// @flow
import * as React from 'react';
import { FormattedMessage } from 'react-intl';
import DonationBands from '../DonationBands/DonationBands';
import Button from '../Button/Button';
import ee from '../../shared/pub_sub';
import Thermometer from '../Thermometer';

import CurrencyAmount from '../../components/CurrencyAmount';

export type Props = {
  donationAmount?: number,
  donationBands: { [id: string]: number[] },
  donationFeaturedAmount?: number,
  currency: string,
  nextStepTitle?: React.Element<any>,
  selectAmount: (amount: ?number) => void,
  changeCurrency: (currency: string) => void,
  proceed: () => void,
};

export type State = {
  customAmount: ?number,
  currencyDropdVisible: boolean,
};

export default class AmountSelection extends React.Component<Props, State> {
  static title(amount: ?number, currency: string): any {
    if (amount == null) {
      return (
        <FormattedMessage id="fundraiser.amount" defaultMessage="AMOUNT" />
      );
    }
    return <CurrencyAmount amount={amount} currency={currency} />;
  }

  constructor(props: Props) {
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

  onSelectCurrency(currency: string): void {
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
        <Thermometer donations={1000} goal={600000} currencyCode={'USD'} />
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
            onChange={(e: SyntheticEvent<HTMLSelectElement>) =>
              this.onSelectCurrency(e.currentTarget.value)
            }
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
