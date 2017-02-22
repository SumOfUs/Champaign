// @flow
import React, { Component } from 'react';
import _ from 'lodash';
import ChampaignAPI from '../../util/ChampaignAPI';
import type { OperationResponse } from '../../util/ChampaignAPI';
import { connect } from 'react-redux';
import Select from '../../components/SweetSelect/SweetSelect';
import './Form.scss';

import {
  changeBody,
  changeSubject,
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


      $.post('/api/email_targets', payload);
    };

    return(
      <div>
        <form onSubmit={onSubmit} className='action-form form--big'>
        <div className='form__group'>
          <label>Subject</label>
          <input
            name='email_subject'
            placeholder='subject'
            value={this.props.subject}
            onChange={(event) => this.props.changeSubject(event.currentTarget.value)} />
        </div>

        <div className='form__group'>
          <div className='email__target-body'>
        <label className='email__target-to'>Dear {this.props.to},</label>
          <textarea
            name='email_body'
            value={this.props.body}
            onChange={(event) => this.props.changeBody(event.currentTarget.value)}
            maxLength="9999">
          </textarea>
          </div>
        </div>

        <div className='form__group form__group--half-width form__group--half-width--left'>
          <label>Your Name</label>
          <input
            name='name'
            placeholder='name'
            value={this.props.name}
            onChange={(event) => this.props.changeName(event.currentTarget.value)} />
        </div>

        <div className='form__group form__group--half-width'>
          <label>Your Email</label>
          <input
            name='email'
            placeholder='email'
            value={this.props.email}
            onChange={(event) => this.props.changeEmail(event.currentTarget.value)} />
        </div>
        <div className='form__group'>

        <Select className='form-control'
          value={this.props.fund}
          //onChange={(value) => this.props.changeFund(value)}
          onChange={changeFund}
          label="Select pension fund" name='select-fund' options={funds} />
        </div>

        <div className='form__group'>
            <button className='button action-form__submit-button'>Send Email</button>
          </div>
        </form>
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
});

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeBody: (body: string) => dispatch(changeBody(body)),
  changeSubject: (subject: string) => dispatch(changeSubject(subject)),
  changeName: (name: string) => dispatch(changeName(name)),
  changeEmail: (email: string) => dispatch(changeEmail(email)),
  changeFund: (fund: string) => dispatch(changeFund(fund)),
});

export default connect(mapStateToProps, mapDispatchToProps)(EmailTargetView);
