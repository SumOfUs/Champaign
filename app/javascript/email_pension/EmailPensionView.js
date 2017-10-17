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

  componentDidMount() {
    this.getPensionFunds(this.props.country);
  }

  changeCountry(value) {
    this.getPensionFunds(value);
    this.props.changeCountry(value);
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

  onEmailEditorUpdate = data => {
    console.log(data);
  };

  render() {
    const errorNotice = () => {
      if (!isEmpty(this.state.errors)) {
        return (
          <span className="error-msg left-align">
            <FormattedMessage id="email_tool.form.errors.message" />
          </span>
        );
      }
    };

    const parse = tpl => {
      tpl = tpl.replace(/(?:\r\n|\r|\n)/g, '<br />');
      tpl = template(tpl);
      return tpl(this.props);
    };

    const parseHeader = () => {
      return { __html: parse(this.props.header) };
    };

    const parseFooter = () => {
      return { __html: parse(this.props.footer) };
    };

    const changeFund = value => {
      const contact = find(this.props.pensionFunds, { _id: value });
      this.props.changeFund(contact);
    };

    const showFundSuggestion = () => {
      if (this.state.shouldShowFundSuggestion) {
        return (
          <div className="email-target_box">
            <h3>
              <span>
                We're sorry you couldn't find your pension fund. Send us its
                name and we'll update our records.
              </span>
            </h3>
            <div className="form__group">
              <Input
                name="new_pension_fund"
                label={
                  <FormattedMessage
                    id="email_tool.form.new_pension_fund"
                    defaultMessage="Name of your pension fund"
                  />
                }
                value={this.state.newPensionFundName}
                onChange={value => {
                  this.setState({ newPensionFundName: value });
                }}
              />
            </div>

            <div className="form__group">
              <Button
                disabled={this.state.isSubmittingNewPensionFundName}
                className="button action-form__submit-button"
                onClick={e => {
                  e.preventDefault();
                  this.postSuggestedFund(this.state.newPensionFundName);
                }}
              >
                Send
              </Button>
            </div>
          </div>
        );
      }
    };

    const prepBody = () =>
      `${parseHeader().__html}\n\n${this.props.body}\n\n${parseFooter()
        .__html}`;

    const onSubmit = e => {
      e.preventDefault();

      const valid = this.validateForm();

      if (!valid) return;

      const payload = {
        body: prepBody(),
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

    return (
      <div className="email-target">
        <div className="email-target-form">
          <form onSubmit={onSubmit} className="action-form form--big">
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
              <div className="form__group">
                <SelectCountry
                  value={this.props.country}
                  name="country"
                  filter={[
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
                  ]}
                  label={
                    <FormattedMessage
                      id="email_tool.form.select_country"
                      defaultMessage="Select country (default)"
                    />
                  }
                  className="form-control"
                  errorMessage={this.state.errors.country}
                  onChange={this.changeCountry.bind(this)}
                />
              </div>

              <div className="form__group">
                <Select
                  className="form-control"
                  value={this.props.fundId}
                  onChange={changeFund}
                  errorMessage={this.state.errors.fund}
                  label={
                    <FormattedMessage
                      id="email_pension.form.select_target"
                      defaultMessage="Select a fund (default)"
                    />
                  }
                  name="select-fund"
                  options={this.props.pensionFunds}
                />
              </div>
              <div className="email__target-suggest-fund">
                <p>
                  <a
                    onClick={() =>
                      this.setState({
                        shouldShowFundSuggestion: !this.state
                          .shouldShowFundSuggestion,
                      })}
                  >
                    Can't find your pension fund?
                  </a>
                </p>
                {showFundSuggestion()}
              </div>
            </div>
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
              {errorNotice()}
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
  pensionFunds: Array<string>,
  isSubmitting: boolean,
  to: string,
  fundId: string,
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
  isSubmitting: state.emailTarget.isSubmitting,
  formValues: state.emailTarget.formValues,
});

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeBody: (body: string) => dispatch(changeBody(body)),

  changeCountry: (country: string) => {
    dispatch(changeCountry(country));
  },

  changeSubmitting: (value: boolean) => dispatch(changeSubmitting(true)),
  changeSubject: (subject: string) => dispatch(changeSubject(subject)),
  changePensionFunds: (pensionFunds: Array<string>) =>
    dispatch(changePensionFunds(pensionFunds)),

  changeName: (name: string) => {
    dispatch(changeName(name));
  },

  changeEmail: (email: string) => dispatch(changeEmail(email)),
  changeFund: (fund: string) => dispatch(changeFund(fund)),
});

export default connect(mapStateToProps, mapDispatchToProps)(EmailPensionView);
