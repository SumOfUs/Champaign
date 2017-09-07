// @flow
import React, { PureComponent } from 'react';
import Input from '../SweetInput/SweetInput';
import { FormattedMessage } from 'react-intl';
import { compact, template } from 'lodash';
import type { ErrorMap } from '../../util/ChampaignClient/Base';

type EmailFields = {
  subject: string,
  body: string,
};

type Props = {
  emailBody: string,
  emailFooter?: string,
  emailHeader?: string,
  emailSubject: string,
  name: string,
  errors: ErrorMap,
  onChange: (email: EmailFields) => void,
};

type State = {
  subject: string,
  body: string,
};

export default class EmailEditor extends PureComponent {
  props: Props;
  state: State;
  constructor(props: Props) {
    super(props);
    this.state = {
      subject: this.props.emailSubject,
      body: this.props.emailBody,
    };
  }

  componentDidMount() {
    this.onChange();
  }

  body() {
    return compact([
      this.parse(this.props.emailHeader),
      this.state.body,
      this.parse(this.props.emailFooter),
    ]).join('\n\n');
  }

  parse(templateString?: string = ''): ?string {
    templateString = templateString.replace(/(?:\r\n|\r|\n)/g, '<br />');
    return template(templateString)(this.props);
  }

  onChange() {
    if (typeof this.props.onChange === 'function') {
      this.props.onChange({
        subject: this.state.subject,
        body: this.body(),
      });

      console.log('on change triggered', {
        subject: this.state.subject,
        body: this.body(),
      });
    }
  }

  updateSubject(subject: string) {
    this.setState(s => ({ ...s, subject }), () => this.onChange());
  }

  updateBody(body: string) {
    console.log('update body');
    this.setState(s => ({ ...s, body }), () => this.onChange());
  }

  render() {
    return (
      <div className="EmailEditor">
        <div className="form__group">
          <Input
            name="subject"
            errorMessage={this.props.errors.emailSubject}
            value={this.state.subject}
            label={
              <FormattedMessage
                id="email_target.form.subject"
                defaultMessage="Subject (default)"
              />
            }
            onChange={subject => this.updateSubject(subject)}
          />
        </div>
        <div className="form__group">
          <div className="email__target-body">
            <div
              className="email__target-header"
              dangerouslySetInnerHTML={{
                __html: this.parse(this.props.emailHeader),
              }}
            />
            <textarea
              name="email_body"
              value={this.state.body}
              onChange={({ target }: SyntheticEvent) => {
                target instanceof HTMLTextAreaElement &&
                  this.updateBody(target.value);
              }}
              maxLength="9999"
            />
            <div
              className="email__target-footer"
              dangerouslySetInnerHTML={{
                __html: this.parse(this.props.emailFooter),
              }}
            />
          </div>
        </div>
      </div>
    );
  }
}
