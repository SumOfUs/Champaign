import React, { Component } from 'react';
import { connect } from 'react-redux';
import { compact, get, join, sample, isEmpty } from 'lodash';
import Select from '../../components/SweetSelect/SweetSelect';
import Input from '../../components/SweetInput/SweetInput';
import Button from '../../components/Button/Button';
import FormGroup from '../../components/Form/FormGroup';
import EmailEditor from '../../components/EmailEditor/EmailEditor';
import ErrorMessages from '../../components/ErrorMessages';
import ConsentComponent from '../../components/consent/ConsentComponent';
import { showConsentRequired } from '../../state/consent/index';
import { FormattedMessage } from 'react-intl';
import './EmailToolView.scss';
import { MailerClient } from '../../util/ChampaignClient';
import {
  convertHtmlToPlainText,
  copyToClipboard,
  composeEmailLink,
  buildToEmailForCompose,
} from '../../util/util';

import './EmailToolView';
import consent from '../../modules/consent/consent';

function emailTargetAsSelectOption(target) {
  return {
    label: join(compact([target.name, target.title]), ', '),
    value: target.id,
  };
}

export class EmailToolView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      name: this.props.name,
      email: this.props.email,
      emailService: null,
      subject: this.props.emailSubject,
      body: '', // this is the complete body: header + body + footer
      target: sample(this.props.targets),
      targetsForSelection: this.props.targets.map(emailTargetAsSelectOption),
      clickedCopyBodyButton: false,
      errors: {},
      isSubmitting: false,
      allTargetEmails: this.props.targets,
    };
  }

  targetId() {
    if (this.props.manualTargeting) {
      return get(this.state.target, 'id', undefined);
    } else {
      // EmailToolSender.rb relies on 'all' as target_id in case we're targeting all of the targets.
      return 'all';
    }
  }

  payload() {
    const payload = {
      page_id: this.props.pageId,
      email: {
        body: this.state.body,
        subject: this.state.subject,
        from_name: this.state.name,
        from_email: this.state.email,
        target_id: this.targetId(),
        country: this.props.country,
        email_service: this.state.emailService,
        clicked_copy_body_button: this.state.clickedCopyBodyButton,
      },
      tracking_params: {
        ...this.props.trackingParams,
      },
    };
    // For double optin countries consented field should not have a value
    if (this.props.consented !== null) {
      payload.consented = this.props.consented ? 1 : 0;
    }
    return payload;
  }

  validateForm() {
    const errors = {};
    // For GDPR countries alone this field should have value
    if (this.props.isRequiredNew && this.props.consented === null) {
      this.props.setShowConsentRequired(true);
      errors['consented'] = true;
    }
    this.setState({ errors: errors });
    return isEmpty(errors);
  }

  // Event Handlers
  // Use arrow functions so that we don't create new instances
  // inside `render()` to avoid triggering unnecessary re-renders.

  // onSubmit
  // Attempt to send the email on submit. If successful, we call the
  // onSuccess prop with the selected target. On failure, we update
  // the state with the errors we receive from the backend.

  handleCopyTargetEmailButton = e => {
    e.preventDefault();
    copyToClipboard(
      buildToEmailForCompose(this.getTargetEmails(), this.state.emailService)
    );
  };

  handleCopyBodyButton = e => {
    e.preventDefault();
    copyToClipboard(convertHtmlToPlainText(this.state.body));
    this.setState({ clickedCopyBodyButton: true });
  };

  handleCopySubjectButton = e => {
    e.preventDefault();
    copyToClipboard(convertHtmlToPlainText(this.state.subject));
  };

  getTargetEmails = () => {
    let targetEmails = this.props.manualTargeting
      ? [this.state.target]
      : this.props.targets;
    return targetEmails.map(target => ({
      name: join(compact([target.name, target.title]), ', '),
      email: target.email,
    }));
  };

  handleSendEmail = () => {
    const emailParam = {
      emailService: this.state.emailService,
      toEmails: this.getTargetEmails(),
      subject: this.state.subject,
      body: convertHtmlToPlainText(this.state.body),
    };
    window.open(composeEmailLink(emailParam));
  };

  onSubmit = e => {
    e.preventDefault();
    const valid = this.validateForm();

    if (!valid) return;
    this.handleSendEmail();
    this.setState(s => ({ ...s, isSubmitting: true, errors: {} }));
    MailerClient.sendEmail(this.payload()).then(
      () => {
        this.setState(s => ({ ...s, isSubmitting: false }));
        if (typeof this.props.onSuccess === 'function' && this.state.target) {
          this.props.onSuccess(this.state.target);
        }
      },
      ({ errors }) => {
        this.setState(s => ({ ...s, isSubmitting: false, errors }));
      }
    );
  };

  // onTargetChange
  // Update the selected target. We use the target.id to find the
  // target. If no id is passed, we clear the target property.
  onTargetChange = id => {
    this.setState({
      target: this.state.allTargetEmails.find(t => t.id === id),
    });
  };

  onNameChange = name => this.setState({ name });

  onEmailChange = email => this.setState({ email });

  onEmailServiceChange = emailService => this.setState({ emailService });

  // onEmailEditorChange
  // The EmailEditor component returns a structure
  onEmailEditorUpdate = emailProps => {
    this.setState({ ...emailProps });
  };

  templateVars() {
    return {
      name: this.state.name,
      postal: this.props.postal,
      target: this.state.target,
    };
  }

  render() {
    const { errors } = this.state;
    return (
      <div className="EmailToolView">
        <div className="EmailToolView-form">
          <form className="action-form form--big">
            <div className="EmailToolView-action">
              <h3 className="EmailToolView-title">{this.props.title}</h3>
              <FormGroup>
                {/* Use a <BaseErrorMesages /> component */}
                <ErrorMessages name="This form" errors={errors.base} />
              </FormGroup>
              {this.props.manualTargeting && (
                <FormGroup>
                  <Select
                    clearable={false}
                    name="Target"
                    label={
                      <FormattedMessage id="email_tool.form.select_target" />
                    }
                    value={get(this.state.target, 'id', undefined)}
                    options={this.state.targetsForSelection}
                    onChange={this.onTargetChange}
                  />
                </FormGroup>
              )}

              <FormGroup>
                <Input
                  name="name"
                  hasError={errors.fromName && errors.fromName.length}
                  label={<FormattedMessage id="email_tool.form.your_name" />}
                  value={this.state.name}
                  onChange={this.onNameChange}
                />
                <ErrorMessages
                  name={<FormattedMessage id="email_tool.form.your_name" />}
                  errors={errors.fromName}
                />
              </FormGroup>
              <FormGroup>
                <Input
                  name="email"
                  type="email"
                  hasError={errors.fromEmail && errors.fromEmail.length}
                  label={<FormattedMessage id="email_tool.form.your_email" />}
                  value={this.state.email}
                  onChange={this.onEmailChange}
                />
                <ErrorMessages
                  name={<FormattedMessage id="email_tool.form.your_email" />}
                  errors={errors.fromEmail}
                />
              </FormGroup>

              <EmailEditor
                errors={errors}
                body={this.props.emailBody}
                header={this.props.emailHeader}
                footer={this.props.emailFooter}
                subject={this.state.subject}
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
            {consent.isRequired(
              this.props.countryCode,
              window.champaign.personalization.member
            ) && (
              <ConsentComponent
                alwaysShow={true}
                isRequired={
                  this.props.isRequiredNew || this.props.isRequiredExisting
                }
              />
            )}

            <FormGroup>
              <Button
                disabled={this.state.isSubmitting || !this.state.emailService}
                className="button action-form__submit-button"
                onClick={e => this.onSubmit(e)}
              >
                {this.state.emailService === 'other_email_services' ? (
                  <FormattedMessage
                    id="email_tool.form.submit"
                    defaultMessage="Submit Action"
                  />
                ) : (
                  <FormattedMessage
                    id="email_tool.form.submit_and_send_email"
                    defaultMessage="Submit Action &amp; Send Email"
                  />
                )}
              </Button>
            </FormGroup>
          </form>
        </div>
      </div>
    );
  }
}

export const mapStateToProps = ({ consent }) => {
  const { countryCode, consented, isRequiredNew, isRequiredExisting } = consent;
  return { countryCode, consented, isRequiredNew, isRequiredExisting };
};

export const mapDispatchToProps = dispatch => ({
  setShowConsentRequired: consentRequired =>
    dispatch(showConsentRequired(consentRequired)),
});

export default connect(mapStateToProps, mapDispatchToProps)(EmailToolView);
