import React, { useState, useEffect } from 'react';
import { FormattedMessage } from 'react-intl';
import { pick } from 'lodash';
import SweetInput from '../../components/SweetInput/SweetInput';
import FormGroup from '../../components/Form/FormGroup';
import Button from '../../components/Button/Button';
import ErrorMessages from '../../components/ErrorMessages';
import Editor from '../../components/EmailEditor/EmailEditor';
import Representative from './Representative';
import { sendEmail } from './api';
import './EmailComposer.css';
import {
  convertHtmlToPlainText,
  copyToClipboard,
  composeEmailLink,
  buildToEmailForCompose,
} from '../../util/util';

export default props => {
  const member = window.champaign.personalization.member;
  const [name, setName] = useState(member.name || '');
  const [email, setEmail] = useState(member.email || '');
  const [subject, setSubject] = useState(props.subject);
  const [body, setBody] = useState(props.body);
  const [emailService, setEmailService] = useState(emailService || '');
  const [clickedCopyBodyButton, setClickedCopyBodyButton] = useState(
    clickedCopyBodyButton || false
  );
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState({});

  let targets = props.targets;

  if (!targets) return null;

  const listType = window.__EMAIL_PARLIAMENT_LIST_TYPE__ || ['MP'];

  targets = targets.filter(target => {
    if (listType.includes('MP') && target.type === 'MP') return true;

    if (listType.includes('Councillor') && target.type === 'Councillor')
      return true;
  });

  const onSubmit = async e => {
    e.preventDefault();
    try {
      handleSendEmail();
      setSubmitting(true);

      const result = await sendEmail({
        pageId: window.champaign.page.id,
        recipients: targets
          .map(
            target => `${target.firstName} ${target.surname} (${target.email})`
          )
          .join(','),
        sender: { name, email },
        subject,
        body,
        emailService,
        clickedCopyBodyButton,
        country: 'GB',
      });

      props.onSend(result);
    } catch (data) {
      if (data.errors) {
        setErrors(data.errors);
      }
    } finally {
      setSubmitting(false);
    }
  };
  const onUpdate = data => {
    if (data.subject !== subject) setSubject(data.subject);
    if (data.body !== body) setBody(data.body);
  };

  // const templateVars = {
  //   target,
  //   name,
  //   email,
  // };

  const templateVars = {};

  const handleCopyTargetEmailButton = e => {
    e.preventDefault();
    copyToClipboard(buildToEmailForCompose(getTargetEmails(), emailService));
  };

  const handleCopyBodyButton = e => {
    e.preventDefault();
    copyToClipboard(convertHtmlToPlainText(body));
    setClickedCopyBodyButton(true);
  };

  const handleCopySubjectButton = e => {
    e.preventDefault();
    copyToClipboard(convertHtmlToPlainText(subject));
  };

  const getTargetEmails = () => {
    return targets.map(t => ({
      email: t.email,
      name: `${t.firstName} ${t.surname}`,
    }));
  };

  const handleSendEmail = () => {
    const emailParam = {
      emailService: emailService,
      toEmails: getTargetEmails(),
      subject: subject,
      body: convertHtmlToPlainText(body),
    };
    window.open(composeEmailLink(emailParam));
  };

  const onEmailServiceChange = nextEmailService => {
    if (emailService != nextEmailService) setEmailService(nextEmailService);
  };

  return (
    <section className="EmailComposer form--big">
      <form onSubmit={onSubmit}>
        <h3 className="EmailComposer-title">{props.title}</h3>
        <FormGroup>
          <Representative targets={targets} />
        </FormGroup>
        <FormGroup>
          <SweetInput
            label="Full name"
            name="fullName"
            type="text"
            value={name}
            onChange={setName}
          />
          <ErrorMessages
            name={<FormattedMessage id="email_tool.form.your_name" />}
            errors={errors.from_name}
          />
        </FormGroup>
        <FormGroup>
          <SweetInput
            label="email"
            name="email"
            type="email"
            value={email}
            onChange={setEmail}
          />
          <ErrorMessages
            name={<FormattedMessage id="email_tool.form.your_email" />}
            errors={errors.from_email}
          />
        </FormGroup>
        <FormGroup>
          <Editor
            subject={props.subject}
            body={props.template}
            errors={errors}
            onUpdate={onUpdate}
            templateVars={templateVars}
            templateInterpolate={templateInterpolate}
          />
        </FormGroup>
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
                  disabled={emailService === 'in_app_send'}
                  type="radio"
                  checked={emailService === 'email_client'}
                  onChange={() => onEmailServiceChange('email_client')}
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
                  disabled={emailService === 'in_app_send'}
                  type="radio"
                  checked={emailService === 'gmail'}
                  onChange={() => onEmailServiceChange('gmail')}
                />
                Gmail
              </label>
            </div>

            <div>
              <label>
                <input
                  disabled={emailService === 'in_app_send'}
                  type="radio"
                  checked={emailService === 'outlook'}
                  onChange={() => onEmailServiceChange('outlook')}
                />
                Outlook / Live / Hotmail
              </label>
            </div>

            <div>
              <label>
                <input
                  disabled={emailService === 'in_app_send'}
                  type="radio"
                  checked={emailService === 'yahoo'}
                  onChange={() => onEmailServiceChange('yahoo')}
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
                  disabled={emailService === 'in_app_send'}
                  type="radio"
                  checked={emailService === 'other_email_services'}
                  onChange={() => onEmailServiceChange('other_email_services')}
                />
                <FormattedMessage
                  id="email_tool.form.others"
                  defaultMessage="Others"
                />
              </label>
            </div>
          </div>

          {emailService === 'other_email_services' && (
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
                            onClick={handleCopyTargetEmailButton}
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
                            onClick={handleCopySubjectButton}
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
                            onClick={handleCopyBodyButton}
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
        <FormGroup>
          <Button
            type="submit"
            disabled={submitting || !emailService}
            className="button action-form__submit-button"
          >
            {emailService === 'other_email_services' ? (
              <FormattedMessage
                // id="email_tool.form.submit_action"
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
        </FormGroup>
        <br style={{ clear: 'both' }} />
      </form>
    </section>
  );
};

import { compact, debounce, template, isEqual } from 'lodash';

function templateInterpolate(tpl, values) {
  const options = {
    interpolate: /{{([\s\S]+?)}}/g,
  };
  if (!tpl) return '';
  return template(tpl, options)(values);
}
