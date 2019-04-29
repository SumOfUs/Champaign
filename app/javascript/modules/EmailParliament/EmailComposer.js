// @flow
// $FlowIgnore
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
import type { Target } from './index';
import './EmailComposer.css';
// hack
import '../../components/EmailEditor/EmailEditor.scss';

type Props = {
  postcode: string,
  title: string,
  subject: string,
  template: string,
  target?: Target,
  body?: string,
  onSend: (data: any) => void,
};

export default (props: Props) => {
  const member = window.champaign.personalization.member;
  const [name, setName] = useState(member.name || '');
  const [email, setEmail] = useState(member.email || '');
  const [subject, setSubject] = useState(props.subject);
  const [body, setBody] = useState(props.body);
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState({});

  const target = props.target;

  if (!target) return null;

  const onSubmit = async e => {
    e.preventDefault();
    try {
      setSubmitting(true);
      const result = await sendEmail({
        pageId: window.champaign.page.id,
        recipient: {
          name: target.displayAs,
          email: target.email,
        },
        sender: { name, email },
        subject,
        body,
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

  const templateVars = {
    target,
    name,
    email,
  };

  return (
    <section className="EmailComposer form--big">
      <form onSubmit={onSubmit}>
        <h3 className="EmailComposer-title">{props.title}</h3>
        <FormGroup>
          <Representative target={target} />
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
        <FormGroup>
          <Button
            type="submit"
            disabled={submitting}
            className="button action-form__submit-button"
          >
            <FormattedMessage
              id="email_tool.form.send_email"
              defaultMessage="Send email (default)"
            />
          </Button>
        </FormGroup>
        <br style={{ clear: 'both' }} />
      </form>
    </section>
  );
};

import { compact, debounce, template, isEqual } from 'lodash';

function templateInterpolate(tpl: string, values: any) {
  const options = {
    interpolate: /{{([\s\S]+?)}}/g,
  };
  if (!tpl) return '';
  return template(tpl, options)(values);
}
