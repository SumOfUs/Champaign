// @flow
import React, { Component } from 'react';

import Select from '../components/SweetSelect/SweetSelect';
import type { SelectOption } from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import FormGroup from '../components/Form/FormGroup';
import SelectCountry from '../components/SelectCountry/SelectCountry';

import {
  changeCountry,
  changePensionFunds,
  changeFund,
} from '../state/email_pension/actions';

type Props = {
  country: string,

  changePensionFunds: () => void,
};

type State = {
  shouldShowFundSuggestion: boolean,
  newPensionFundName: string,
  isSubmittingNewPensionFundName: boolean,
  newPensionFundSuggested: boolean,
  errors: {
    country: any,
    fund: any,
  },
};

const SUPPORTED_COUNTRIES = [
  'AU',
  'BE',
  'CA',
  'CH',
  'DE',
  'DK',
  'ES',
  'FI',
  'FR',
  'GB',
  'IE',
  'IS',
  'IT',
  'NL',
  'NO',
  'PT',
  'SE',
  'US',
];

class SelectPensionFund extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);
    this.state = {
      shouldShowFundSuggestion: false,
      newPensionFundName: '',
      isSubmittingNewPensionFundName: false,
      newPensionFundSuggested: false,
      errors: {},
    };
  }

  componentDidMount() {
    this.getPensionFunds(this.props.country);
  }

  getPensionFunds(country: string) {
    if (!country) return;

    const url = `/api/pension_funds?country=${country.toLowerCase()}`;

    const handleSuccess = data => {
      this.props.changePensionFunds(
        data.map(fund => ({
          value: fund._id,
          label: fund.fund,
        }))
      );
    };

    $.getJSON(url).done(handleSuccess);
  }

  postSuggestedFund(fund: string) {
    if (!fund) return;

    const url = '/api/pension_funds/suggest_fund';

    this.setState({ isSubmittingNewPensionFundName: true });

    $.post(url, { 'email_tool[name]': fund })
      .done(a => {
        this.setState({
          shouldShowFundSuggestion: false,
          newPensionFundName: '',
          newPensionFundSuggested: true,
          isSubmittingNewPensionFundName: false,
        });
      })
      .fail(a => {
        console.log('err');
      });
  }

  render() {
    return (
      <div className="SelectPensionFund">
        <SelectCountry
          value={this.props.country}
          name="country"
          filter={SUPPORTED_COUNTRIES}
          label={
            <FormattedMessage
              id="email_tool.form.select_country"
              defaultMessage="Select country (default)"
            />
          }
          className="form-control"
          errorMessage={this.state.errors.country}
          onChange={this.changeCountry.bind(this)}
        />{' '}
      </div>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SelectPensionFund);
