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
  componentWillMount() {
    this.getPensionFunds(this.props.country);
  }

  getPensionFunds = country => {
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

  onChangeCountry = country => {
    this.getPensionFunds(country);
    this.props.changeCountry(country);
    this.props.onChangeCountry(country);
  };

  changeFund = _id => {
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

function mapStateToProps(state) {
  return {
    country: state.emailTarget.country,
    pensionFunds: state.emailTarget.pensionFunds,
    fundId: state.emailTarget.fundId,
    fund: state.emailTarget.fund,
  };
}

function mapDispatchToProps(disp) {
  return {
    changeCountry: country => disp(changeCountry(country)),
    changePensionFunds: funds => disp(changePensionFunds(funds)),
    changeFund: fund => disp(changeFund(fund)),
  };
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(SelectPensionFund);
