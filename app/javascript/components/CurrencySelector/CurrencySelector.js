import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { changeCurrency } from '../../state/fundraiser/actions';

import type { AppState } from '../../state/reducers';

type Props = {};

type State = {
  currencyDropdVisible: boolean,
};

class CurrencySelector extends Component<Props> {
  constructor(props: Props) {
    super(props);
    this.state = {
      currencyDropdVisible: false,
    };
  }

  toggleCurrencyDropd() {
    this.setState({
      currencyDropdVisible: !this.state.currencyDropdVisible,
    });
  }

  onSelectCurrency(currency: string): void {
    this.props.changeCurrency(currency);
  }

  selectElement() {
    return (
      this.state.currencyDropdVisible && (
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
      )
    );
  }

  render() {
    return (
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
        {this.selectElement()}
      </p>
    );
  }
}

const mapState = (state: AppState) => ({
  currency: state.fundraiser.currency,
  donationBands: state.fundraiser.donationBands,
});

const mapDispatch = (dispatch: Dispatch<*>) => ({
  changeCurrency: (currency: string) => dispatch(changeCurrency(currency)),
});

export default connect(
  mapState,
  mapDispatch
)(CurrencySelector);
