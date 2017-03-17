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

import {
  changeBody,
  changeSubject,
  changeSubmitting,
  changeEmail,
  changeName,
  changeFund,
} from '../../state/email_target/actions';

import type { Dispatch } from 'redux';

const fundsData = {
  'FUND A' : {
    contact_name: "Bob",
    email: "osahyoun@gmail.com",
    fund_name: "FUND A",
  },

  'FUND B' : {
    contact_name: "George",
    email: "omar+fund-b@sumofus.org",
    fund_name: 'FUND B',
  },
};

class EmailTargetView extends Component {
  render() {

    const changeFund = (value) => {
      const contact = fundsData[value];
      this.props.changeFund(contact);
    };

    const funds = [
      {value: 'FUND A', label: 'Fund A'},
      {value: 'FUND B', label: 'Fund B'},
    ];

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
          <Select className='form-control'
            value={this.props.fund}
            onChange={changeFund}
            label="Select pension fund" name='select-fund' options={funds} />
        </div>


        <div className='form__group'>
          <Input
            name='email_subject'
            label='Subject'
            value={this.props.subject}
            onChange={(value) => this.props.changeSubject(value)} />
        </div>

        <div className='form__group form__group--half-width form__group--half-width--left'>
          <Input
            name='name'
            label='Your Name'
            value={this.props.name}
            required={true}
            onChange={(value) => this.props.changeName(value)} />

        </div>

        <div className='form__group form__group--half-width'>
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
  email: state.emailTarget.email,
  name: state.emailTarget.name,
  fund: state.emailTarget.fund,
  fundContact: state.emailTarget.fundContact,
  fundEmail: state.emailTarget.fundEmail,
  to: state.emailTarget.to,
  page: state.emailTarget.page,
  isSubmitting: state.emailTarget.isSubmitting,
});

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeBody: (body: string) => dispatch(changeBody(body)),
  changeSubmitting: (value: boolean) => dispatch(changeSubmitting(true)),
  changeSubject: (subject: string) => dispatch(changeSubject(subject)),
  changeName: (name: string) => {
    console.log('hello');
    dispatch(changeName(name));
  },
  changeEmail: (email: string) => dispatch(changeEmail(email)),
  changeFund: (fund: string) => dispatch(changeFund(fund)),
});

export default connect(mapStateToProps, mapDispatchToProps)(EmailTargetView);
