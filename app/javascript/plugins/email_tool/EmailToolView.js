import React, { Component } from 'react';
import { compact, get, join, sample, template } from 'lodash';
import Select from '../../components/SweetSelect/SweetSelect';
import Input from '../../components/SweetInput/SweetInput';
import Button from '../../components/Button/Button';
import FormGroup from '../../components/Form/FormGroup';
import EmailEditor from '../../components/EmailEditor/EmailEditor';
import ErrorMessages from '../../components/ErrorMessages';
import { FormattedMessage } from 'react-intl';
import './EmailToolView.scss';
import { MailerClient } from '../../util/ChampaignClient';

import './EmailToolView';

function emailTargetAsSelectOption(target) {
  return {
    label: join(compact([target.name, target.title]), ', '),
    value: target.id,
  };
}

export default class EmailToolView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      name: this.props.name,
      email: this.props.email,
      emailService: null,
      subject: this.props.emailSubject,
      body: '', // this is the complete body: header + body + footer
      target: sample(this.props.targets),
      targetsForSelection: props.targets.map(emailTargetAsSelectOption),
      clickedCopyBodyButton: false,
      errors: {},
      isSubmitting: false,
    };
  }

  targetId() {
    if (this.props.manualTargeting) {
      return get(this.state.target, 'id', undefined);
    }
  }

  payload() {
    return {
      page_id: this.props.pageId,
      email: {
        body: this.state.body,
        subject: this.state.subject,
        from_name: this.state.name,
        from_email: this.state.email,
        target_id: this.targetId(),
        country: this.props.country,
        email_service: this.state.emailService,
      },
      tracking_params: {
        ...this.props.trackingParams,
        clicked_copy_body_button: this.state.clickedCopyBodyButton,
      },
    };
  }

  // Event Handlers
  // Use arrow functions so that we don't create new instances
  // inside `render()` to avoid triggering unnecessary re-renders.

  // onSubmit
  // Attempt to send the email on submit. If successful, we call the
  // onSuccess prop with the selected target. On failure, we update
  // the state with the errors we receive from the backend.

  convertHtmlToPlainText = htmlValue => {
    let htmlElement = document.createElement('div');
    htmlElement.innerHTML = htmlValue;
    return htmlElement.textContent || htmlElement.innerText || '';
  }; //Should move this to Utils once feature is done

  copyToClipboard = content => {
    const htmlElement = document.createElement('textarea');
    htmlElement.value = content;
    document.body.appendChild(htmlElement);
    htmlElement.select();
    document.execCommand('copy');
    document.body.removeChild(htmlElement);
  };

  handleCopyBodyButton = content => {
    this.copyToClipboard(this.convertHtmlToPlainText(this.state.body));
    this.setState({ clickedCopyBodyButton: true });
  };

  emailComposingLink = () => {
    const target_email = encodeURIComponent(this.state.target?.email);
    const cc_email = encodeURIComponent(this.state.email);
    const subject = encodeURIComponent(this.state.subject);
    const body = encodeURIComponent(
      this.convertHtmlToPlainText(this.state.body)
    );
    let host, urlParams;

    switch (this.state.emailService) {
      case 'email_client':
        return `mailto:${target_email}?cc=${cc_email}&subject=${subject}&body=${body}`;
      case 'gmail':
        host = 'https://mail.google.com/mail/?view=cm&fs=1&tf=1&';
        urlParams = `to=${target_email}&cc=${cc_email}&su=${subject}&body=${body}`;
        return `${host}${urlParams}`;
      case 'outlook':
        host = 'https://outlook.com/?path=/mail/action/compose&';
        urlParams = `to=${target_email}&cc=${cc_email}&subject=${subject}&body=${body}`;
        return `${host}${urlParams}`;
      case 'yahoo':
        host = 'https://compose.mail.yahoo.com/?';
        urlParams = `to=${target_email}&cc=${cc_email}&subject=${subject}&body=${body}`;
        return `${host}${urlParams}`;
      default:
        return `mailto:${target_email}?cc=${cc_email}&subject=${subject}&body=${body}`;
    }
  };

  handleSendEmail = () => {
    if (this.state.emailService != 'other_email_services')
      window.open(this.emailComposingLink());
  };

  onSubmit = e => {
    e.preventDefault();
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
    this.setState({ target: this.props.targets.find(t => t.id === id) });
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
              {/* <div>
                <Button
                  className="button"
                  onClick={() => window.open(this.generateMailToLink())}
                >
                  <FormattedMessage
                    id="email_tool.form.send_email"
                    defaultMessage="Send with your email client (default)"
                  />
                </Button>
              </div> */}

              <div className="section title">
                <FormattedMessage
                  id="email_tool.form.choose_email_service"
                  defaultMessage="If you have not set up an email client or the above button does not open your email, please use the following instructions. (default)"
                />
              </div>

              <div className="section" style={{ display: 'flex' }}>
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
                    Outlook/Live/Hotmail
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
              </div>
              <div className="section" style={{ display: 'flex' }}>
                <div>
                  <label>
                    <input
                      disabled={this.state.emailService === 'in_app_send'}
                      type="radio"
                      checked={this.state.emailService === 'email_client'}
                      onChange={e => this.onEmailServiceChange('email_client')}
                    />
                    Email Client
                  </label>
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
                    Others
                  </label>
                </div>
              </div>

              {this.state.emailService === 'other_email_services' && (
                <React.Fragment>
                  <div className="section">
                    <FormattedMessage
                      id="email_tool.form.title_for_no_email_client"
                      defaultMessage="If you have not set up an email client or the above button does not open your email, please use the following instructions. (default)"
                    />
                  </div>
                  <div className="section">
                    <span>1. </span>
                    <span>
                      <Button
                        className="copy-button"
                        onClick={e => {
                          e.preventDefault();
                          this.copyToClipboard(this.state.target?.email);
                        }}
                      >
                        <i className="fa fa-copy"></i>
                      </Button>
                    </span>
                    <span>
                      <FormattedMessage
                        id="email_tool.form.copy_target_email_address"
                        defaultMessage="Copy Target Email Address (default)"
                      />
                    </span>
                  </div>

                  <div className="section">
                    <span>2. </span>
                    <span>
                      <Button
                        className="copy-button"
                        onClick={e => {
                          e.preventDefault();
                          this.copyToClipboard(this.state.subject);
                        }}
                      >
                        <i className="fa fa-copy"></i>
                      </Button>
                    </span>
                    <span>
                      <FormattedMessage
                        id="email_tool.form.copy_email_subject"
                        defaultMessage="Copy Email Subject (default)"
                      />
                    </span>
                  </div>

                  <div className="section">
                    <span>3. </span>
                    <span>
                      <Button
                        className="copy-button"
                        onClick={e => {
                          e.preventDefault();
                          this.handleCopyBodyButton();
                        }}
                      >
                        <i className="fa fa-copy"></i>
                      </Button>
                    </span>
                    <span>
                      <FormattedMessage
                        id="email_tool.form.copy_email_body"
                        defaultMessage="Copy Email Body (default)"
                      />
                    </span>
                  </div>
                </React.Fragment>
              )}
            </div>

            <FormGroup>
              <Button
                disabled={this.state.isSubmitting || !this.state.emailService}
                className="button action-form__submit-button"
                onClick={e => this.onSubmit(e)}
              >
                {this.state.emailService === 'other_email_services' ? (
                  <FormattedMessage
                    // id="email_tool.form.submit_action"
                    id="email_tool.form.send_email"
                    defaultMessage="Submit Action (default)"
                  />
                ) : (
                  <FormattedMessage
                    // id="email_tool.form.submit_action"
                    id="email_tool.form.submit_and_send_email"
                    defaultMessage="Submit Action &amp; Send Email(default)"
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
