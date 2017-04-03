// @flow
import React, { Component } from 'react';
import _ from 'lodash';
import $ from 'jquery';
import { connect } from 'react-redux';
import Select from '../../components/SweetSelect/SweetSelect';
import './EmailTargetView.scss';
import Input from '../../components/SweetInput/SweetInput';
import Button from '../../components/Button/Button';
import SelectCountry from '../../components/SelectCountry/SelectCountry';
import { FormattedMessage } from 'react-intl';

import {
  changeCountry,
  changeBody,
  changeSubject,
  changeSubmitting,
  changePensionFunds,
  changeEmail,
  changeName,
  changeFund,
} from '../../state/email_target/actions';

import type { Dispatch } from 'redux';

class EmailTargetView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      shouldShowFundSuggestion: false
    };
  }

  componentDidMount() {
    this.getPensionFunds(this.props.country);
  }

  getPensionFunds(country: string) {
    if(!country) return;

    const url = `/api/pension_funds?country=${country.toLowerCase()}`;

    const handleSuccess = (data) => {
      data.forEach((fund) => {
        fund.value = fund._id;
        fund.label = fund.fund;
      });

      this.props.changePensionFunds(data);
    };

    $.getJSON(url).done(handleSuccess);
  }

  changeCountry(value) {
    this.getPensionFunds(value);
    this.props.changeCountry(value);
  }

  render() {

    const toWho = () => {
      return `Dear ${this.props.fundContact || '[select a fund]'},`;
    };

    const fromWho = () => {
      return `Regards, ${this.props.name || '[enter your name]'}`;
    };

    const changeFund = (value) => {
      const contact = _.find(this.props.pensionFunds, {_id: value});
      this.props.changeFund(contact);
    };

    const showFundSuggestion = () => {
      if (this.state.shouldShowFundSuggestion){
        return(
          <p>
            <FormattedMessage id="email_target.suggest_fund" />
          </p>
        );
      }
    };

    const onSubmit = (e) => {
      e.preventDefault();

      const payload = {
        body: this.props.body,
        subject: this.props.subject,
        page: this.props.page,
        target_name: this.props.fund,
        country: this.props.country,
        from_name: this.props.name,
        from_email: this.props.email,
        to_name: this.props.fundContact,
        to_email: this.props.fundEmail,
      };

      this.props.changeSubmitting(true);

      $.post('/api/email_targets', payload).done((a,b,c) => {

      });
    };

    return(
      <div className='email-target'>
        <div className='email-target-form'>
        <form onSubmit={onSubmit} className='action-form form--big'>
          <div className='email-target-action'>
            <h2>
              <FormattedMessage id="email_target.section.select_target" defaultMessage="Select Your Target" />
            </h2>

            <div className='form__group'>
              <SelectCountry
                value={this.props.country}
                name='country'
                label={<FormattedMessage id="email_target.form.select_country" defaultMessage="Select country (default)" />}
                className='form-control'
                onChange={this.changeCountry.bind(this)} />
            </div>

            <div className='form__group'>
              <Select className='form-control'
                value={this.props.fundId}
                onChange={changeFund}
                label={<FormattedMessage id="email_target.form.select_target" defaultMessage="Select a fund (default)" />}
                name='select-fund' options={this.props.pensionFunds} />
            </div>
            <div className='email__target-suggest-fund'>
              <p><a onClick={() => this.setState({shouldShowFundSuggestion: !this.state.shouldShowFundSuggestion})} >Can't find your pension fund?</a></p>
              { showFundSuggestion() }
            </div>
          </div>
          <div className='email-target-action'>
            <h2>
              <FormattedMessage id="email_target.section.compose" defaultMessage="Compose Your Email" />
            </h2>

            <div className='form__group'>
              <Input
                name='email_subject'
                value={this.props.subject}
                label={<FormattedMessage id="email_target.form.subject" defaultMessage="Subejct (default)" />}
                onChange={(value) => this.props.changeSubject(value)} />
            </div>

          <div className='form__group'>
            <Input
              name='name'
              label={<FormattedMessage id="email_target.form.your_name" defaultMessage="Your name (default)" />}
              value={this.props.name}
              required={true}
              onChange={(value) => this.props.changeName(value)} />
          </div>

          <div className='form__group'>
            <Input
              name='email'
              label={<FormattedMessage id="email_target.form.your_email" defaultMessage="Your email (default)" />}
              value={this.props.email}
              required={true}
              onChange={(value) => this.props.changeEmail(value) } />
          </div>

          <div className='form__group'>
            <div className='email__target-body'>
            <span className='email__target-greeting'>
              <Input
                readonly='true'
                value={toWho()} />
            </span>
            <textarea
              name='email_body'
              value={this.props.body}
              onChange={(event) => this.props.changeBody(event.currentTarget.value)}
              maxLength="9999">
            </textarea>
            <span className='email__target-sign-off'>
              <Input
                readonly='true'
                value={fromWho()} />
            </span>
          </div>
          </div>
        </div>

        <div className='form__group'>
          <Button disabled={this.props.isSubmitting} className='button action-form__submit-button'>
            <FormattedMessage id="email_target.form.send_email" defaultMessage="Send email (default)" />
          </Button>
        </div>
      </form>
      </div>

    </div>
    );
  }
}

type EmailTargetType = {
  emailBody: string,
  emailSubject: string,
  country: string,
  email: string,
  name: string,
  pensionFunds: Array<string>,
  isSubmitting: boolean,
  to: string,
  fundId: string,
  fund: string,
  fundContact: string,
  fundEmail: string,
  page: string,
}

type OwnState = {
  emailTarget: EmailTargetType,
}

export const mapStateToProps = (state: OwnState) => ({
  body: state.emailTarget.emailBody,
  subject: state.emailTarget.emailSubject,
  country: state.emailTarget.country,
  email: state.emailTarget.email,
  name: state.emailTarget.name,
  pensionFunds: state.emailTarget.pensionFunds,
  fundId: state.emailTarget.fundId,
  fund: state.emailTarget.fund,
  fundContact: state.emailTarget.fundContact,
  fundEmail: state.emailTarget.fundEmail,
  to: state.emailTarget.to,
  page: state.emailTarget.page,
  isSubmitting: state.emailTarget.isSubmitting,
});

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeBody: (body: string) => dispatch(changeBody(body)),

  changeCountry: (country: string) => {
    dispatch(changeCountry(country));
  },

  changeSubmitting: (value: boolean) => dispatch(changeSubmitting(true)),
  changeSubject: (subject: string) => dispatch(changeSubject(subject)),
  changePensionFunds: (pensionFunds: Array<string>) => dispatch(changePensionFunds(pensionFunds)),

  changeName: (name: string) => {
    dispatch(changeName(name));
  },

  changeEmail: (email: string) => dispatch(changeEmail(email)),
  changeFund: (fund: string) => dispatch(changeFund(fund)),
});

export default connect(mapStateToProps, mapDispatchToProps)(EmailTargetView);
