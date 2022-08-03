import React, { useState } from 'react';
import { FormattedMessage } from 'react-intl';
import { isEmpty } from 'lodash';
import { useDispatch, useSelector } from 'react-redux';

import ConsentComponent from '../../components/consent/ConsentComponent';
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
import { showConsentRequired } from '../../state/consent';
import consent from '../../modules/consent/consent';

export function EmailComposer(props) {
  const dispatch = useDispatch();

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

  const isRequiredNew = useSelector(state => state.consent.isRequiredNew);
  const isRequiredExisting = useSelector(
    state => state.consent.isRequiredExisting
  );
  const consented = useSelector(state => state.consent.consented);

  let targets = props.targets;

  if (!targets) return null;

  const listType = __EMAIL_PARLIAMENT_LIST_TYPE__ || ['MP'];

  targets = targets.filter(target => {
    if (listType.includes('MP') && target.type === 'MP') return true;

    if (listType.includes('Councillor') && target.type === 'Councillor')
      return true;
  });

  const onSubmit = async e => {
    e.preventDefault();

    const valid = validateForm();
    if (!valid) return;

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
        consented: consented ? 1 : 0,
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

  const validateForm = () => {
    const errors = {};
    if (isRequiredNew && consented === null) {
      dispatch(showConsentRequired(true));
      errors['consented'] = true;
    }
    setErrors({ errors: errors });
    return isEmpty(errors);
  };

  // Sent as template variable values to interpolate
  const templateVars = {
    target: {
      name: targets[0].firstName + ' ' + targets[0].surname,
      party: targets[0].partyAffiliation,
      ...targets[0],
    },
    name,
    email,
    postal: member.postal,
  };

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
        <ConsentComponent
          alwaysShow={true}
          isRequired={isRequiredNew || isRequiredExisting}
        />
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
}

/*

  ! Commenting it out since we are sticking to ${} as template [Refer https://app.asana.com/0/1119304937718815/1201038772171675/f]

  function templateInterpolate(tpl, values) {
    const options = {
      interpolate: /{{([\s\S]+?)}}/g,
    };
    if (!tpl) return '';
    return template(tpl, options)(values);
  }

*/
