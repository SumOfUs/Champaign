// @flow
import React, { Component } from 'react';
import Select from '../components/SweetSelect/SweetSelect';
import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import SelectCountry from '../components/SelectCountry/SelectCountry';
import { FormattedMessage } from 'react-intl';
import './EmailToolView.scss';

type Props = {
  emailBody: string,
  emailHeader: string,
  emailFooter: string,
  emailSubject: string,
  country: string,
  email: string,
  name: string,
  pensionFunds: Array<string>,
  isSubmitting: boolean,
  to: string,
  fundId: string,
  fund: string,
  fundContact: string,
  fundEmail: string,
  page: string,
};

type State = {
  name: string,
  errors: { [field: string]: string },
};

export default class EmailToolView extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);
    this.state = {
      name: '',
      errors: {},
    };
  }

  onSubmit = e => {
    e.preventDefault();
  };

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

  parse(template) {
    template = template.replace(/(?:\r\n|\r|\n)/g, '<br />');
    template = _.template(template);
    return template(this.props);
  }

  render() {
    return (
      <div className="email-target">
        <div className="email-target-form">
          <form onSubmit={this.onSubmit} className="action-form form--big">
            <div className="email-target-action">
              <h3>
                <FormattedMessage
                  id="email_target.section.compose"
                  defaultMessage="Compose Your Email"
                />
              </h3>

              <div className="form__group">
                <Input
                  name="email_subject"
                  errorMessage={this.state.errors.emailSubject}
                  value={this.props.emailSubject}
                  label={
                    <FormattedMessage
                      id="email_target.form.subject"
                      defaultMessage="Subject (default)"
                    />
                  }
                  onChange={subject => this.setState(s => ({ ...s, subject }))}
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
                  value={this.props.name}
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
                  value={this.props.email}
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
                    onChange={emailBody =>
                      this.setState(s => ({ ...s, emailBody }))}
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
