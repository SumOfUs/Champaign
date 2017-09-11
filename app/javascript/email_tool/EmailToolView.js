// @flow
import React, { Component } from 'react';
import { compact, get, join, sample, template } from 'lodash';
import Select from '../components/SweetSelect/SweetSelect';
import type { SelectOption } from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import FormGroup from '../components/Form/FormGroup';
import EmailEditor from '../components/EmailEditor/EmailEditor';
import ErrorMessages from '../components/ErrorMessages';
import type { EmailProps } from '../components/EmailEditor/EmailEditor';
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
  manualTargeting: boolean,
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
    label: join(compact([target.name, target.title]), ', '),
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

  targetId(): ?string {
    if (this.props.manualTargeting) {
      return get(this.state.target, 'id', undefined);
    }
  }

  payload(): ChampaignEmailPayload {
    return {
      body: this.state.body,
      country: this.props.country,
      from_name: this.state.name,
      from_email: this.state.email,
      page_id: this.props.pageId,
      subject: this.state.subject,
      target_id: this.targetId(),
    };
  }

  // Event Handlers
  // Use arrow functions so that we don't create new instances
  // inside `render()` to avoid triggering unnecessary re-renders.

  // onSubmit
  // Attempt to send the email on submit. If successful, we call the
  // onSuccess prop with the selected target. On failure, we update
  // the state with the errors we receive from the backend.
  onSubmit = (e: SyntheticEvent) => {
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
  };

  // onTargetChange
  // Update the selected target. We use the target.id to find the
  // target. If no id is passed, we clear the target property.
  onTargetChange = (id: ?string) => {
    this.setState(state => ({
      ...state,
      target: this.props.targets.find(t => t.id === id),
    }));
  };

  onNameChange = (name: string) => this.setState(s => ({ ...s, name }));

  onEmailChange = (email: string) => this.setState(s => ({ ...s, email }));

  // onEmailEditorChange
  // The EmailEditor component returns a structure
  onEmailEditorUpdate = (emailProps: EmailProps) => {
    this.setState(s => ({
      ...s,
      ...emailProps,
    }));
  };

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
          <form onSubmit={this.onSubmit} className="action-form form--big">
            <div className="EmailToolView-action">
              <h3 className="EmailToolView-title">
                <FormattedMessage
                  id="email_tool.section.compose"
                  defaultMessage="Compose Your Email"
                />
              </h3>
              <FormGroup>
                <ErrorMessages
                  name="This form"
                  errors={this.state.errors.base}
                />
              </FormGroup>
              {this.props.manualTargeting && (
                <FormGroup>
                  <Select
                    clearable={false}
                    name="Target"
                    label="Select a target"
                    value={get(this.state.target, 'id', undefined)}
                    options={this.state.targetsForSelection}
                    onChange={this.onTargetChange}
                  />
                </FormGroup>
              )}

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
                  errorMessage={
                    <ErrorMessages
                      name="Name"
                      errors={this.state.errors.fromName}
                    />
                  }
                  onChange={this.onNameChange}
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
                  errorMessage={
                    <ErrorMessages
                      name="Email"
                      errors={this.state.errors.fromEmail}
                    />
                  }
                  onChange={this.onEmailChange}
                />
              </FormGroup>
              <EmailEditor
                errors={this.state.errors}
                emailBody={this.props.emailBody}
                emailHeader={this.props.emailHeader}
                emailFooter={this.props.emailFooter}
                emailSubject={this.props.emailSubject}
                templateVars={this.templateVars()}
                onUpdate={this.onEmailEditorUpdate}
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
