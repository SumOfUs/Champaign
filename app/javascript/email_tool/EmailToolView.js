// @flow
import React, { Component } from 'react';
import { get, sample, template } from 'lodash';
import Select from '../components/SweetSelect/SweetSelect';
import type { SelectOption } from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import { FormattedMessage } from 'react-intl';
import './EmailToolView.scss';
import { MailerClient } from '../util/ChampaignClient';

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

type State = Props & {
  target: ?EmailTarget,
  targetsForSelection: SelectOption[],
  errors: { [field: string]: string },
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
      ...this.props,
      target: sample(this.props.targets),
      targetsForSelection: props.targets.map(emailTargetAsSelectOption),
      errors: {},
    };
  }

  fromEmail(): string {
    if (this.state.useMemberEmail) {
      return this.state.email;
    }

    return this.state.emailFrom;
  }

  payload(): ChampaignEmailPayload {
    return {
      body: this.prepBody(),
      country: this.state.country,
      from_name: this.state.name,
      from_email: this.fromEmail(),
      page_id: this.props.pageId,
      subject: this.state.emailSubject,
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

  parseHeader() {
    return { __html: this.parse(this.props.emailHeader) };
  }

  parseFooter() {
    return { __html: this.parse(this.props.emailFooter) };
  }

  prepBody() {
    return `${this.parseHeader().__html}\n\n${this.props
      .emailBody}\n\n${this.parseFooter().__html}`;
  }

  parse(templateString: string) {
    templateString = templateString.replace(/(?:\r\n|\r|\n)/g, '<br />');
    return template(templateString)(this.state);
  }

  updateBody(emailBody: string) {
    return this.setState(s => ({ ...s, emailBody }));
  }

  updateTarget(id: ?string) {
    this.setState(state => ({
      ...state,
      target: this.props.targets.find(t => t.id === id),
    }));
  }

  targetsAsOptions() {
    return this.props.targets.map(target => ({
      label: target.name,
      value: target,
    }));
  }

  render() {
    return (
      <div className="email-target">
        <div className="email-target-form">
          <form
            onSubmit={e => this.onSubmit(e)}
            className="action-form form--big"
          >
            <div className="email-target-action">
              <h3>
                <FormattedMessage
                  id="email_target.section.compose"
                  defaultMessage="Compose Your Email"
                />
              </h3>
              <div className="form__group">
                <Select
                  clearable={false}
                  name="Target"
                  label="Select a target"
                  value={get(this.state.target, 'id', undefined)}
                  options={this.state.targetsForSelection}
                  onChange={id => this.updateTarget(id)}
                />
                <br />
              </div>

              <div className="form__group">
                <Input
                  name="subject"
                  errorMessage={this.state.errors.emailSubject}
                  value={this.state.emailSubject}
                  label={
                    <FormattedMessage
                      id="email_target.form.subject"
                      defaultMessage="Subject (default)"
                    />
                  }
                  onChange={emailSubject =>
                    this.setState(s => ({ ...s, emailSubject }))}
                />
              </div>

              <div className="form__group">
                <Input
                  name="name"
                  label={
                    <FormattedMessage
                      id="email_target.form.your_name"
                      defaultMessage="Your name (default)"
                    />
                  }
                  value={this.state.name}
                  errorMessage={this.state.errors.name}
                  onChange={name => this.setState(s => ({ ...s, name }))}
                />
              </div>

              <div className="form__group">
                <Input
                  name="email"
                  type="email"
                  label={
                    <FormattedMessage
                      id="email_target.form.your_email"
                      defaultMessage="Your email (default)"
                    />
                  }
                  value={this.state.email}
                  errorMessage={this.state.errors.email}
                  onChange={email => this.setState(s => ({ ...s, email }))}
                />
              </div>

              <div className="form__group">
                <div className="email__target-body">
                  <div
                    className="email__target-header"
                    dangerouslySetInnerHTML={this.parseHeader()}
                  />
                  <textarea
                    name="email_body"
                    value={this.state.emailBody}
                    onChange={({ target }: SyntheticEvent) => {
                      target instanceof HTMLTextAreaElement &&
                        this.updateBody(target.value);
                    }}
                    maxLength="9999"
                  />
                  <div
                    className="email__target-footer"
                    dangerouslySetInnerHTML={this.parseFooter()}
                  />
                </div>
              </div>
            </div>

            <div className="form__group">
              <Button
                disabled={this.state.isSubmitting}
                className="button action-form__submit-button"
              >
                <FormattedMessage
                  id="email_target.form.send_email"
                  defaultMessage="Send email (default)"
                />
              </Button>
            </div>
          </form>
        </div>
      </div>
    );
  }
}
