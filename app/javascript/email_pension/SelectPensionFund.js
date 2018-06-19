// @flow
import $ from 'jquery';
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { find, sortBy } from 'lodash';
import Select from '../components/SweetSelect/SweetSelect';
import type { SelectOption } from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import FormGroup from '../components/Form/FormGroup';
import SelectCountry from '../components/SelectCountry/SelectCountry';
import SuggestFund from './SuggestFund';

import {
  changeCountry,
  changePensionFunds,
  changeFund,
} from '../state/email_pension/actions';

type Props = {
  errors: {
    country: any,
    fund: any,
  },
} & typeof mapStateToProps &
  typeof mapDispatchToProps;

const SUPPORTED_COUNTRIES: string[] = [
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

  componentWillMount() {
    this.getPensionFunds(this.props.country);
  }

  getPensionFunds = (country: string) => {
    if (!country) return;

    const url = `/api/pension_funds?country=${country.toLowerCase()}`;

    $.getJSON(url)
      .then(data => {
        // $FlowIgnore
        return sortBy(data, [o => o.fund.toLowerCase()]).map(f => ({
          ...f,
          value: f._id,
          label: f.fund,
        }));
      })
      .then(this.props.changePensionFunds);
  };

  onChangeCountry = (country: string) => {
    this.getPensionFunds(country);
    this.props.changeCountry(country);
  };

  changeFund = (_id: string) => {
    const contact = find(this.props.pensionFunds, { _id });
    this.props.changeFund(contact);
  };

  render() {
    return (
      <div className="SelectPensionFund">
        <FormGroup>
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
            errorMessage={this.props.errors.country}
            onChange={this.onChangeCountry}
          />
        </FormGroup>
        <FormGroup>
          <Select
            className="form-control"
            value={this.props.fundId}
            errorMessage={this.props.errors.fund}
            label={
              <FormattedMessage
                id="email_pension.form.select_target"
                defaultMessage="Select a fund (default)"
              />
            }
            name="select-fund"
            options={this.props.pensionFunds}
            onChange={this.changeFund}
          />
        </FormGroup>
        <SuggestFund />
      </div>
    );
  }
}

function mapStateToProps(state: any) {
  return {
    country: state.emailTarget.country,
    pensionFunds: state.emailTarget.pensionFunds,
    fundId: state.emailTarget.fundId,
    fund: state.emailTarget.fund,
  };
}

function mapDispatchToProps(disp) {
  return {
    changeCountry: (country: string) => disp(changeCountry(country)),
    changePensionFunds: (funds: string[]) => disp(changePensionFunds(funds)),
    changeFund: (fund: string) => disp(changeFund(fund)),
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(SelectPensionFund);
