import React, { Component } from 'react';
import { isEmpty, find, template, merge } from 'lodash';
import $ from 'jquery';
import { connect } from 'react-redux';
import Select from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import SelectCountry from '../components/SelectCountry/SelectCountry';
import FormGroup from '../components/Form/FormGroup';
import EmailEditor from '../components/EmailEditor/EmailEditor';
import { FormattedMessage } from 'react-intl';
import SelectPensionFund from './SelectPensionFund';
import './EmailPensionView.scss';

import {
  changeCountry,
  changeBody,
  changeSubject,
  changeSubmitting,
  changePensionFunds,
  changeEmail,
  changeName,
  changeFund,
} from '../state/email_pension/actions';

import type { Dispatch } from 'redux';

class EmailPensionView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      shouldShowFundSuggestion: false,
      newPensionFundName: '',
      isSubmittingNewPensionFundName: false,
      newPensionFundSuggested: false,
      errors: {},
    };
  }

  validateForm() {
    const errors = {};

    const fields = ['country', 'subject', 'name', 'email', 'fund'];

    fields.forEach(field => {
      if (isEmpty(this.props[field])) {
        const location = `email_tool.form.errors.${field}`;
        const message = <FormattedMessage id={location} />;
        errors[field] = message;
      }
    });

    this.setState({ errors: errors });
    return isEmpty(errors);
  }

  templateVars() {
    return {
      ...this.props,
      ...this.state,
    };
  }

  onEmailEditorUpdate = ({ subject, body }) => {
    this.props.changeSubject(subject);
    this.setState(state => ({ ...state, body }));
  };

  errorNotice = () => {
    if (!isEmpty(this.state.errors)) {
      return (
        <span className="error-msg left-align">
          <FormattedMessage id="email_tool.form.errors.message" />
        </span>
      );
    }
  };

  onSubmit = e => {
    e.preventDefault();

    const valid = this.validateForm();

    if (!valid) return;

    const payload = {
      body: this.state.body,
      subject: this.props.subject,
      target_name: this.props.fund,
      country: this.props.country,
      from_name: this.props.name,
      from_email: this.props.email,
      to_name: this.props.fundContact,
      to_email: this.props.fundEmail,
    };

    merge(payload, this.props.formValues);

    this.props.changeSubmitting(true);
    // FIXME Handle errors
    $.post(`/api/pages/${this.props.pageId}/pension_emails`, payload);
  };

  render() {
    return (
      <div className="email-target">
        <div className="email-target-form">
          <form onSubmit={this.onSubmit} className="action-form form--big">
            <SelectPensionFund
              country={this.props.country}
              fund={this.props.fundId}
              onChange={changeFund}
              errors={{
                country: this.state.errors.country,
                fund: this.state.errors.fund,
              }}
            />
            <div className="email-target-action">
              <h3>
                <FormattedMessage
                  id="email_tool.section.compose"
                  defaultMessage="Compose Your Email"
                />
              </h3>

              <FormGroup>
                <Input
                  name="name"
                  label={
                    <FormattedMessage
                      id="email_tool.form.your_name"
                      defaultMessage="Your name (default)"
                    />
                  }
                  value={this.props.name}
                  errorMessage={this.state.errors.name}
                  onChange={value => this.props.changeName(value)}
                />
              </FormGroup>

              <FormGroup>
                <Input
                  name="email"
                  label={
                    <FormattedMessage
                      id="email_tool.form.your_email"
                      defaultMessage="Your email (default)"
                    />
                  }
                  value={this.props.email}
                  errorMessage={this.state.errors.country}
                  onChange={value => this.props.changeEmail(value)}
                />
              </FormGroup>

              <EmailEditor
                errors={this.state.errors}
                body={this.props.emailBody}
                header={this.props.emailHeader}
                footer={this.props.emailFooter}
                subject={this.props.emailSubject}
                templateVars={this.templateVars()}
                onUpdate={this.onEmailEditorUpdate}
              />
            </div>

            <div className="form__group">
              <Button
                disabled={this.props.isSubmitting}
                className="button action-form__submit-button"
              >
                <FormattedMessage
                  id="email_tool.form.send_email"
                  defaultMessage="Send email (default)"
                />
              </Button>
              {this.errorNotice()}
            </div>
          </form>
        </div>
      </div>
    );
  }
}

type EmailPensionType = {
  emailBody: string,
  emailHeader: string,
  emailFooter: string,
  emailSubject: string,
  country: string,
  email: string,
  name: string,
  isSubmitting: boolean,
  to: string,
  fund: string,
  fundContact: string,
  fundEmail: string,
};

type OwnState = {
  emailTarget: EmailPensionType,
};

export const mapStateToProps = (state: OwnState) => ({
  body: state.emailTarget.emailBody,
  header: state.emailTarget.emailHeader,
  footer: state.emailTarget.emailFooter,
  fundContact: state.emailTarget.fundContact,
  subject: state.emailTarget.emailSubject,
  country: state.emailTarget.country,
  email: state.emailTarget.email,
  name: state.emailTarget.name,
  fund: state.emailTarget.fund,
  to: state.emailTarget.to,
  isSubmitting: state.emailTarget.isSubmitting,
  formValues: state.emailTarget.formValues,
});

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeSubmitting: (value: boolean) => dispatch(changeSubmitting(true)),
  changeSubject: (subject: string) => dispatch(changeSubject(subject)),
  changeName: (name: string) => {
    dispatch(changeName(name));
  },
  changeEmail: (email: string) => dispatch(changeEmail(email)),
});

export default connect(mapStateToProps, mapDispatchToProps)(EmailPensionView);
