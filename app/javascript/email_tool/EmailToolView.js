// @flow
import React, { Component } from 'react';
import { get, sample, template } from 'lodash';
import Select from '../components/SweetSelect/SweetSelect';
import type { SelectOption } from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import FormGroup from '../components/Form/FormGroup';
import EmailEditor from '../components/EmailEditor/EmailEditor';
import { FormattedMessage } from 'react-intl';
import './EmailToolView.scss';
import { MailerClient } from '../util/ChampaignClient';
import type { ErrorMap } from '../util/ChampaignClient/Base';

import './EmailToolView';

type ChampaignEmailPayload = any;

export interface EmailTarget {
  id: string,
  title?: string,
  name: string,
  email: string,
}

type Props = {
  emailBody: string,
  emailHeader: string,
  emailFooter: string,
  emailFrom: string,
  emailSubject: string,
  country: string,
  email: string,
  name: string,
  isSubmitting: boolean,
  page: string,
  pageId: number,
  targets: EmailTarget[],
  useMemberEmail: boolean,
  onSuccess?: (target: EmailTarget) => void,
};

type State = {
  name: string,
  email: string,
  subject: string,
  body: string,
  target: ?EmailTarget,
  targetsForSelection: SelectOption[],
  errors: ErrorMap,
  isSubmitting: boolean,
};

function emailTargetAsSelectOption(target: EmailTarget): SelectOption {
  return {
    label: target.title ? `${target.name}, ${target.title}` : target.name,
    value: target.id,
  };
}

export default class EmailToolView extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);
    this.state = {
      name: this.props.name,
      email: this.props.email,
      subject: this.props.emailSubject,
      body: '', // this is the complete body: header + body + footer
      target: sample(this.props.targets),
      targetsForSelection: props.targets.map(emailTargetAsSelectOption),
      errors: {},
      isSubmitting: false,
    };
  }

  payload(): ChampaignEmailPayload {
    return {
      body: this.state.body,
      country: this.props.country,
      from_name: this.state.name,
      from_email: this.state.email,
      page_id: this.props.pageId,
      subject: this.state.subject,
      target_id: get(this.state.target, 'id', undefined),
    };
  }

  onSubmit(e: SyntheticEvent) {
    e.preventDefault();
    this.setState(s => ({ ...s, isSubmitting: true, errors: [] }));
    MailerClient.sendEmail(this.payload()).then(
      ({ errors }) => {
        this.setState(s => ({ ...s, isSubmitting: false, errors }));
        if (typeof this.props.onSuccess === 'function' && this.state.target) {
          this.props.onSuccess(this.state.target);
        }
      },
      ({ errors }) => {
        this.setState(s => ({ ...s, isSubmitting: false, errors }));
      }
    );
  }

  updateTarget(id: ?string) {
    this.setState(state => ({
      ...state,
      target: this.props.targets.find(t => t.id === id),
    }));
  }

  templateVars() {
    return {
      name: this.state.name,
      target: this.state.target,
    };
  }

  render() {
    return (
      <div className="EmailToolView">
        <div className="EmailToolView-form">
          <form
            onSubmit={e => this.onSubmit(e)}
            className="action-form form--big"
          >
            <div className="EmailToolView-action">
              <h3 className="EmailToolView-title">
                <FormattedMessage
                  id="email_tool.section.compose"
                  defaultMessage="Compose Your Email"
                />
              </h3>
              <FormGroup>
                <Select
                  clearable={false}
                  name="Target"
                  label="Select a target"
                  value={get(this.state.target, 'id', undefined)}
                  options={this.state.targetsForSelection}
                  onChange={id => this.updateTarget(id)}
                />
              </FormGroup>

              <FormGroup>
                <Input
                  name="name"
                  label={
                    <FormattedMessage
                      id="email_tool.form.your_name"
                      defaultMessage="Your name (default)"
                    />
                  }
                  value={this.state.name}
                  errorMessage={this.state.errors.name}
                  onChange={name => this.setState(s => ({ ...s, name }))}
                />
              </FormGroup>
              <FormGroup>
                <Input
                  name="email"
                  type="email"
                  label={
                    <FormattedMessage
                      id="email_toolt.form.your_email"
                      defaultMessage="Your email (default)"
                    />
                  }
                  value={this.state.email}
                  errorMessage={this.state.errors.email}
                  onChange={email => this.setState(s => ({ ...s, email }))}
                />
              </FormGroup>
              <EmailEditor
                errors={this.state.errors}
                emailBody={this.props.emailBody}
                emailHeader={this.props.emailHeader}
                emailFooter={this.props.emailFooter}
                emailSubject={this.props.emailSubject}
                templateVars={this.templateVars()}
                onChange={data =>
                  this.setState(s => ({
                    ...s,
                    body: data.body,
                    subject: data.subject,
                  }))}
              />
            </div>

            <FormGroup>
              <Button
                disabled={this.state.isSubmitting}
                className="button action-form__submit-button"
              >
                <FormattedMessage
                  id="email_tool.form.send_email"
                  defaultMessage="Send email (default)"
                />
              </Button>
            </FormGroup>
          </form>
        </div>
      </div>
    );
  }
}
