// @flow
import React, { Component } from 'react';
import _ from 'lodash';
import ChampaignAPI from '../../util/ChampaignAPI';
import type { OperationResponse } from '../../util/ChampaignAPI';
import { connect } from 'react-redux';
import Select from '../../components/SweetSelect/SweetSelect';
import './Form.scss';
import Input from '../../components/SweetInput/SweetInput';
import FieldShape from '../../components/FieldShape/FieldShape';
import Button from '../../components/Button/Button';
import SelectCountry from '../../components/SelectCountry/SelectCountry';

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
  componentDidMount() {
    this.getPensionFunds(this.props.country);
  }

  getPensionFunds(country) {
    if(!country) return;

    $.getJSON(`/api/pension_funds?country=${country.toLowerCase()}`).
     done((data) => {
      data.forEach((fund) => {
        fund.value = fund._id;
        fund.label = fund.fund;
      });

      this.props.changePensionFunds(data);
    });
  }

  changeCountry(value) {
    this.getPensionFunds(value);
    this.props.changeCountry(value);
  }

  render() {
    const changeFund = (value) => {
      const contact = _.find(this.props.pensionFunds, {_id: value});
      this.props.changeFund(contact);
    };

    const onSubmit = (e) => {
      e.preventDefault();

      const payload = {
        body: this.props.body,
        subject: this.props.subject,
        page: this.props.page,
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
        <div className='form__group'>
          <SelectCountry
            value={this.props.country}
            name='country'
            label='Select country'
            className='form-control'
            onChange={this.changeCountry.bind(this)}
            />
        </div>

        <div className='form__group'>
          <Select className='form-control'
            value={this.props.fundId}
            onChange={changeFund}
            label="Select pension fund" name='select-fund' options={this.props.pensionFunds} />
        </div>


        <div className='form__group'>
          <Input
            name='email_subject'
            label='Subject'
            value={this.props.subject}
            onChange={(value) => this.props.changeSubject(value)} />
        </div>

        <div className='form__group'>
          <Input
            name='name'
            label='Your Name'
            value={this.props.name}
            required={true}
            onChange={(value) => this.props.changeName(value)} />

        </div>

        <div className='form__group'>
          <Input
            name='email'
            label='Your Email'
            value={this.props.email}
            required={true}
            onChange={(value) => this.props.changeEmail(value) } />
        </div>

        <div className='form__group'>
          <div className='email__target-body'>

          <textarea
            name='email_body'
            value={this.props.body}
            onChange={(event) => this.props.changeBody(event.currentTarget.value)}
            maxLength="9999">
          </textarea>
          </div>
        </div>

        <div className='form__group'>
          <Button disabled={this.props.isSubmitting ? 'disabled': ''} className='button action-form__submit-button'>Send Email</Button>
        </div>
      </form>
      </div>

    </div>
    );
  }
}

export const mapStateToProps = (state) => ({
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
  changePensionFunds: (pensionFunds: array) => dispatch(changePensionFunds(pensionFunds)),

  changeName: (name: string) => {
    dispatch(changeName(name));
  },

  changeEmail: (email: string) => dispatch(changeEmail(email)),
  changeFund: (fund: string) => dispatch(changeFund(fund)),
});

export default connect(mapStateToProps, mapDispatchToProps)(EmailTargetView);
