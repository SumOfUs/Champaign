import React, { Component } from 'react';
import { isEmpty, find, template, merge, each, pick } from 'lodash';

import { connect } from 'react-redux';
import Select from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import SelectCountry from '../components/SelectCountry/SelectCountry';
import FormGroup from '../components/Form/FormGroup';
import EmailEditor from '../components/EmailEditor/EmailEditor';
import { FormattedMessage, injectIntl } from 'react-intl';
import SelectPensionFund from './SelectPensionFund';
import './EmailPensionView.scss';
import ConsentComponent from '../consent/ConsentComponent';

import {
  changeBody,
  changeSubject,
  changeSubmitting,
  changePensionFunds,
  changeEmail,
  changeName,
  changeFund,
  changeConsented,
} from '../state/email_pension/actions';

import type { Dispatch } from 'redux';
import { changeCountry } from '../state/consent/index';

class EmailPensionView extends Component {
  constructor(props) {
    super(props);
    this.defaultTemplateVars = {
      fundContact: this.props.intl.formatMessage({
        id: 'email_tool.template_defaults.fund_contact',
      }),
      fundEmail: this.props.intl.formatMessage({
        id: 'email_tool.template_defaults.fund_email',
      }),
      fund: this.props.intl.formatMessage({
        id: 'email_tool.template_defaults.fund',
      }),
      name: this.props.intl.formatMessage({
        id: 'email_tool.template_defaults.name',
      }),
    };

    this.state = {
      shouldShowFundSuggestion: false,
      newPensionFundName: '',
      isSubmittingNewPensionFundName: false,
      newPensionFundSuggested: false,
      errors: {},
    };
    this.store = window.champaign.store;
  }

  validateForm() {
    const errors = {};

    const fields = ['country', 'emailSubject', 'name', 'email', 'fund'];

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
    let vars = pick(this.props, [
      'name',
      'fund',
      'fundContact',
      'fundEmail',
      'email',
      'country',
      'postal',
    ]);

    each(this.defaultTemplateVars, (val, key) => {
      if (vars[key] === undefined || vars[key] === '') {
        vars[key] = val;
      }
    });
    return vars;
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

  changeConsent = (consented: boolean) => {
    this.props.changeConsent(consented);
  };

  changeAppStateCountry = country => {
    if (this.store) {
      this.store.dispatch(changeCountry(country));
    }
  };

  onSubmit = e => {
    e.preventDefault();

    const valid = this.validateForm();
    if (!valid) return;

    const payload = {
      email: {
        body: this.state.body,
        subject: this.props.emailSubject,
        target_name: this.props.fund,
        country: this.props.country,
        from_name: this.props.name,
        from_email: this.props.email,
        to_name: this.props.fundContact,
        to_email: this.props.fundEmail,
      },
      consented: this.props.consented ? 1 : 0,
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
              onChangeCountry={this.changeAppStateCountry}
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
                  type="email"
                  label={
                    <FormattedMessage
                      id="email_tool.form.your_email"
                      defaultMessage="Your email (default)"
                    />
                  }
                  value={this.props.email}
                  errorMessage={this.state.errors.email}
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
            <ConsentComponent consentChanged={this.changeConsent} />
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
  email: string,
  name: string,
  isSubmitting: boolean,
  fundContact: string,
  fundEmail: string,
  fund: string,
  fundId: string,
  country: string,
};

type OwnState = {
  emailTarget: EmailPensionType,
};

export const mapStateToProps = (state: OwnState) =>
  pick(state.emailTarget, [
    'email',
    'name',
    'country',
    'emailSubject',
    'isSubmitting',
    'fundContact',
    'fundEmail',
    'fund',
    'fundId',
    'consented',
  ]);

export const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  changeSubmitting: (value: boolean) => dispatch(changeSubmitting(true)),
  changeSubject: (subject: string) => dispatch(changeSubject(subject)),
  changeName: (name: string) => {
    dispatch(changeName(name));
  },
  changeEmail: (email: string) => dispatch(changeEmail(email)),
  changeConsent: (consented: boolean) => dispatch(changeConsented(consented)),
});

export default injectIntl(
  connect(
    mapStateToProps,
    mapDispatchToProps
  )(EmailPensionView)
);
