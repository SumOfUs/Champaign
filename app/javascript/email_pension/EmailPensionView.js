import React, { Component } from 'react';
import _ from 'lodash';
import $ from 'jquery';
import { connect } from 'react-redux';
import Select from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import SelectCountry from '../components/SelectCountry/SelectCountry';
import { FormattedMessage } from 'react-intl';
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

  postSuggestedFund(fund: string) {
    if (!fund) return;

    const url = '/api/pension_funds/suggest_fund';

    this.setState({ isSubmittingNewPensionFundName: true });

    $.post(url, { 'email_target[name]': fund })
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

  getPensionFunds(country: string) {
    if (!country) return;

    const url = `/api/pension_funds?country=${country.toLowerCase()}`;

    const handleSuccess = data => {
      data.forEach(fund => {
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

  validateForm() {
    const errors = {};

    const fields = ['country', 'subject', 'name', 'email', 'fund'];

    fields.forEach(field => {
      if (_.isEmpty(this.props[field])) {
        const location = `email_target.form.errors.${field}`;
        const message = <FormattedMessage id={location} />;
        errors[field] = message;
      }
    });

    this.setState({ errors: errors });
    return _.isEmpty(errors);
  }

  render() {
    const errorNotice = () => {
      if (!_.isEmpty(this.state.errors)) {
        return (
          <span className="error-msg left-align">
            <FormattedMessage id="email_target.form.errors.message" />
          </span>
        );
      }
    };

    const parse = template => {
      template = template.replace(/(?:\r\n|\r|\n)/g, '<br />');
      template = _.template(template);
      return template(this.props);
    };

    const parseHeader = () => {
      return { __html: parse(this.props.header) };
    };

    const parseFooter = () => {
      return { __html: parse(this.props.footer) };
    };

    const changeFund = value => {
      const contact = _.find(this.props.pensionFunds, { _id: value });
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
                    id="email_target.form.new_pension_fund"
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
        page: this.props.page,
        target_name: this.props.fund,
        country: this.props.country,
        from_name: this.props.name,
        from_email: this.props.email,
        to_name: this.props.fundContact,
        to_email: this.props.fundEmail,
      };

      _.merge(payload, this.props.formValues);

      this.props.changeSubmitting(true);
      $.post('/api/email_targets', payload).done((a, b, c) => {});
    };

    return (
      <div className="email-target">
        <div className="email-target-form">
          <form onSubmit={onSubmit} className="action-form form--big">
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
                      id="email_target.form.select_country"
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
                      id="email_target.form.select_target"
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
                  id="email_target.section.compose"
                  defaultMessage="Compose Your Email"
                />
              </h3>

              <div className="form__group">
                <Input
                  name="email_subject"
                  errorMessage={this.state.errors.subject}
                  value={this.props.subject}
                  label={
                    <FormattedMessage
                      id="email_target.form.subject"
                      defaultMessage="Subejct (default)"
                    />
                  }
                  onChange={value => this.props.changeSubject(value)}
                />
              </div>

              <div className="form__group">
                <Input
                  name="name"
                  label={
                    <FormattedMessage
                      id="email_target.form.your_name"
                      defaultMessage="Your name (default)"
                    />
                  }
                  value={this.props.name}
                  errorMessage={this.state.errors.name}
                  onChange={value => this.props.changeName(value)}
                />
              </div>

              <div className="form__group">
                <Input
                  name="email"
                  label={
                    <FormattedMessage
                      id="email_target.form.your_email"
                      defaultMessage="Your email (default)"
                    />
                  }
                  value={this.props.email}
                  errorMessage={this.state.errors.country}
                  onChange={value => this.props.changeEmail(value)}
                />
              </div>

              <div className="form__group">
                <div className="email__target-body">
                  <div
                    className="email__target-header"
                    dangerouslySetInnerHTML={parseHeader()}
                  />
                  <textarea
                    name="email_body"
                    value={this.props.body}
                    onChange={event =>
                      this.props.changeBody(event.currentTarget.value)}
                    maxLength="9999"
                  />
                  <div
                    className="email__target-footer"
                    dangerouslySetInnerHTML={parseFooter()}
                  />
                </div>
              </div>
            </div>

            <div className="form__group">
              <Button
                disabled={this.props.isSubmitting}
                className="button action-form__submit-button"
              >
                <FormattedMessage
                  id="email_target.form.send_email"
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
  page: string,
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
  page: state.emailTarget.page,
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
