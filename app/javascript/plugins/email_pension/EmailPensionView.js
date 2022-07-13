//
import React, { Component } from 'react';
import { isEmpty, find, template, merge, each, pick, join } from 'lodash';

import { connect } from 'react-redux';
import Select from '../../components/SweetSelect/SweetSelect';
import Input from '../../components/SweetInput/SweetInput';
import Button from '../../components/Button/Button';
import SelectCountry from '../../components/SelectCountry/SelectCountry';
import FormGroup from '../../components/Form/FormGroup';
import EmailEditor from '../../components/EmailEditor/EmailEditor';
import { FormattedMessage, injectIntl } from 'react-intl';
import SelectPensionFund from './SelectPensionFund';
import './EmailPensionView.scss';
import ConsentComponent from '../../components/consent/ConsentComponent';

import {
  changeBody,
  changeSubject,
  changeSubmitting,
  changePensionFunds,
  changeEmail,
  changeName,
  changeFund,
  changeConsented,
} from '../../state/email_pension/actions';
import { showConsentRequired } from '../../state/consent/index';
import {
  convertHtmlToPlainText,
  copyToClipboard,
  composeEmailLink,
  buildToEmailForCompose,
} from '../../util/util';

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
      clickedCopyBodyButton: false,
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
    // For GDPR countries alone this field should have value
    if (this.props.isRequiredNew && this.props.consented === null) {
      this.props.showConsentRequired(true);
      errors['consented'] = true;
    }
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

  validateFormBeforeCopying = () => {
    if (!this.validateForm()) {
      alert('Form has errors. Please fix before copying.');
    }
  };

  handleCopyTargetEmailButton = e => {
    e.preventDefault();
    this.validateFormBeforeCopying();
    copyToClipboard(
      buildToEmailForCompose(
        this.composeTargetAddress(),
        this.state.emailService
      )
    );
  };

  handleCopyBodyButton = e => {
    e.preventDefault();
    this.validateFormBeforeCopying();
    copyToClipboard(convertHtmlToPlainText(this.state.body));
    this.setState({ clickedCopyBodyButton: true });
  };

  handleCopySubjectButton = e => {
    e.preventDefault();
    this.validateFormBeforeCopying();
    copyToClipboard(convertHtmlToPlainText(this.props.emailSubject));
  };

  composeTargetAddress() {
    return [{ name: this.props.fundContact, email: this.props.fundEmail }];
  }

  handleSendEmail = () => {
    const emailParam = {
      emailService: this.state.emailService,
      toEmails: this.composeTargetAddress(),
      subject: this.props.emailSubject,
      body: convertHtmlToPlainText(this.state.body),
    };
    window.open(composeEmailLink(emailParam));
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
    this.handleSendEmail();
    const payload = {
      body: this.state.body,
      subject: this.props.emailSubject,
      target_name: this.props.fund,
      country: this.props.country,
      from_name: this.props.name,
      from_email: this.props.email,
      to_name: this.props.fundContact,
      to_email: this.props.fundEmail,
      consented: this.props.consented ? 1 : 0,
      email_service: this.state.emailService,
      clicked_copy_body_button: this.state.clickedCopyBodyButton,
    };
    merge(payload, this.props.formValues);
    this.props.changeSubmitting(true);

    // FIXME Handle errors
    $.post(`/api/pages/${this.props.pageId}/pension_emails`, payload);
  };

  onEmailServiceChange = emailService => this.setState({ emailService });

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
                      defaultMessage="Your name"
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
                      defaultMessage="Your email"
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

            <div className="EmailToolView-note">
              <div className="section title">
                <FormattedMessage
                  id="email_tool.form.choose_email_service"
                  defaultMessage="If you have not set up an email client or the above button does not open your email, please use the following instructions."
                />
              </div>

              <div className="section">
                <div className="title">
                  <span>
                    <FormattedMessage
                      id="email_tool.form.mobile_desktop_apps"
                      defaultMessage="Mobile &amp; Desktop Apps"
                    />
                  </span>
                </div>
                <div>
                  <label>
                    <input
                      disabled={this.state.emailService === 'in_app_send'}
                      type="radio"
                      checked={this.state.emailService === 'email_client'}
                      onChange={e => this.onEmailServiceChange('email_client')}
                    />
                    <FormattedMessage
                      id="email_tool.form.email_client"
                      defaultMessage="Email Client"
                    />
                  </label>
                </div>
                <div className="title">
                  <span>
                    <FormattedMessage
                      id="email_tool.form.web_browser"
                      defaultMessage="Web Browser"
                    />
                  </span>
                </div>
                <div>
                  <label>
                    <input
                      disabled={this.state.emailService === 'in_app_send'}
                      type="radio"
                      checked={this.state.emailService === 'gmail'}
                      onChange={e => this.onEmailServiceChange('gmail')}
                    />
                    Gmail
                  </label>
                </div>

                <div>
                  <label>
                    <input
                      disabled={this.state.emailService === 'in_app_send'}
                      type="radio"
                      checked={this.state.emailService === 'outlook'}
                      onChange={e => this.onEmailServiceChange('outlook')}
                    />
                    Outlook / Live / Hotmail
                  </label>
                </div>

                <div>
                  <label>
                    <input
                      disabled={this.state.emailService === 'in_app_send'}
                      type="radio"
                      checked={this.state.emailService === 'yahoo'}
                      onChange={e => this.onEmailServiceChange('yahoo')}
                    />
                    Yahoo Mail
                  </label>
                </div>
                <div className="title">
                  <span>
                    <FormattedMessage
                      id="email_tool.form.manual"
                      defaultMessage="Manual"
                    />
                  </span>
                </div>
                <div>
                  <label>
                    <input
                      disabled={this.state.emailService === 'in_app_send'}
                      type="radio"
                      checked={
                        this.state.emailService === 'other_email_services'
                      }
                      onChange={e =>
                        this.onEmailServiceChange('other_email_services')
                      }
                    />
                    <FormattedMessage
                      id="email_tool.form.others"
                      defaultMessage="Others"
                    />
                  </label>
                </div>
              </div>

              {this.state.emailService === 'other_email_services' && (
                <React.Fragment>
                  <div className="section">
                    <FormattedMessage
                      id="email_tool.form.title_for_no_email_client"
                      defaultMessage="If you have not set up an email client or the above button does not open your email, please use the following instructions."
                    />
                  </div>
                  <div className="section">
                    <table>
                      <tbody>
                        <tr>
                          <td>
                            <span>
                              <FormattedMessage
                                id="email_tool.form.copy_target_email_address"
                                defaultMessage="Copy Target Email Address"
                              />
                            </span>
                          </td>
                          <td>
                            <span>
                              <Button
                                className="copy-button"
                                onClick={this.handleCopyTargetEmailButton}
                              >
                                <i className="fa fa-copy"></i>
                              </Button>
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <span>
                              <FormattedMessage
                                id="email_tool.form.copy_email_subject"
                                defaultMessage="Copy Email Subject"
                              />
                            </span>
                          </td>
                          <td>
                            <span>
                              <Button
                                className="copy-button"
                                onClick={this.handleCopySubjectButton}
                              >
                                <i className="fa fa-copy"></i>
                              </Button>
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <span>
                              <FormattedMessage
                                id="email_tool.form.copy_email_body"
                                defaultMessage="Copy Email Body"
                              />
                            </span>
                          </td>
                          <td>
                            <span>
                              <Button
                                className="copy-button"
                                onClick={this.handleCopyBodyButton}
                              >
                                <i className="fa fa-copy"></i>
                              </Button>
                            </span>
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </React.Fragment>
              )}
            </div>
            <ConsentComponent
              alwaysShow={true}
              isRequired={
                this.props.isRequiredNew || this.props.isRequiredExisting
              }
            />
            <div className="form__group">
              <Button
                disabled={this.state.isSubmitting || !this.state.emailService}
                className="button action-form__submit-button"
              >
                {this.state.emailService === 'other_email_services' ? (
                  <FormattedMessage
                    id="email_tool.form.submit"
                    defaultMessage="Submit Action"
                  />
                ) : (
                  <FormattedMessage
                    // id="email_tool.form.submit_action"
                    id="email_tool.form.submit_and_send_email"
                    defaultMessage="Submit Action &amp; Send Email"
                  />
                )}
              </Button>
              {this.errorNotice()}
            </div>
          </form>
        </div>
      </div>
    );
  }
}

export const mapStateToProps = ({ emailTarget, consent }) => {
  const {
    email,
    name,
    country,
    emailSubject,
    isSubmitting,
    fundContact,
    fundEmail,
    fund,
    fundId,
  } = emailTarget;
  const { consented, isRequiredNew, isRequiredExisting } = consent;
  return {
    email,
    name,
    country,
    emailSubject,
    isSubmitting,
    fundContact,
    fundEmail,
    fund,
    fundId,
    consented,
    isRequiredNew,
    isRequiredExisting,
  };
};

export const mapDispatchToProps = dispatch => ({
  changeSubmitting: value => dispatch(changeSubmitting(true)),
  changeSubject: subject => dispatch(changeSubject(subject)),
  changeName: name => {
    dispatch(changeName(name));
  },
  changeEmail: email => dispatch(changeEmail(email)),
  showConsentRequired: consentRequired =>
    dispatch(showConsentRequired(consentRequired)),
});

export default injectIntl(
  connect(mapStateToProps, mapDispatchToProps)(EmailPensionView)
);
