// @flow
import React, { Component } from 'react';
import { compact, get, join, sample, template } from 'lodash';
import Select from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import FormGroup from '../components/Form/FormGroup';
import EmailEditor from '../components/EmailEditor/EmailEditor';
import ErrorMessages from '../components/ErrorMessages';
import { FormattedMessage } from 'react-intl';
import './EmailToolView.scss';
import { MailerClient } from '../util/ChampaignClient';

import type { EmailProps } from '../components/EmailEditor/EmailEditor';
import type { ErrorMap } from '../util/ChampaignClient/Base';
import type { SelectOption } from 'react-select';

import './EmailToolView';

type ChampaignEmailPayload = any;

export interface EmailTarget {
  id: string;
  title?: string;
  name: string;
  email: string;
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
  postal: string,
  isSubmitting: boolean,
  page: string,
  pageId: number,
  targets: EmailTarget[],
  title: string,
  useMemberEmail: boolean,
  manualTargeting: boolean,
  onSuccess?: (target: EmailTarget) => void,
  trackingParams?: { [key: string]: string },
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

export default class EmailToolView extends Component<Props, State> {
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
      page_id: this.props.pageId,
      email: {
        body: this.state.body,
        subject: this.state.subject,
        from_name: this.state.name,
        from_email: this.state.email,
        target_id: this.targetId(),
        country: this.props.country,
      },
      tracking_params: this.props.trackingParams,
    };
  }

  // Event Handlers
  // Use arrow functions so that we don't create new instances
  // inside `render()` to avoid triggering unnecessary re-renders.

  // onSubmit
  // Attempt to send the email on submit. If successful, we call the
  // onSuccess prop with the selected target. On failure, we update
  // the state with the errors we receive from the backend.
  onSubmit = (e: SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
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
  onTargetChange = (id: ?string) => {
    this.setState({ target: this.props.targets.find(t => t.id === id) });
  };

  onNameChange = (name: string) => this.setState({ name });

  onEmailChange = (email: string) => this.setState({ email });

  // onEmailEditorChange
  // The EmailEditor component returns a structure
  onEmailEditorUpdate = (emailProps: EmailProps) => {
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
          <form onSubmit={this.onSubmit} className="action-form form--big">
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
