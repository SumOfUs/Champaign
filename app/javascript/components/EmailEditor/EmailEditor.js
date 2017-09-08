// @flow
import React, { PureComponent } from 'react';
import Input from '../SweetInput/SweetInput';
import FormGroup from '../Form/FormGroup';
import { FormattedMessage } from 'react-intl';
import { compact, get, template } from 'lodash';
import type { ErrorMap } from '../../util/ChampaignClient/Base';
import './EmailEditor.scss';

type EmailFields = {
  subject: string,
  body: string,
};

type Props = {
  emailBody: string,
  emailFooter?: string,
  emailHeader?: string,
  emailSubject: string,
  templateVars: { [key: string]: any },
  errors: ErrorMap,
  onChange: (email: EmailFields) => void,
};

export default class EmailEditor extends PureComponent {
  props: Props;
  state: EmailFields;
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
    return template(templateString)(this.props.templateVars);
  }

  onChange() {
    if (typeof this.props.onChange === 'function') {
      this.props.onChange({
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
    const { emailHeader, emailFooter, errors } = this.props;
    return (
      <div className="EmailEditor">
        <FormGroup>
          <Input
            name="subject"
            errorMessage={errors.emailSubject}
            value={this.state.subject}
            label={
              <FormattedMessage
                id="email_tool.form.subject"
                defaultMessage="Subject (default)"
              />
            }
            onChange={subject => this.updateSubject(subject)}
          />
        </FormGroup>
        <FormGroup>
          <div className="EmailEditor-body">
            {emailHeader && (
              <div
                className="EmailEditor-header"
                dangerouslySetInnerHTML={{ __html: this.parse(emailHeader) }}
              />
            )}
            <textarea
              name="email_body"
              value={this.state.body}
              onChange={({ target }: SyntheticEvent) => {
                target instanceof HTMLTextAreaElement &&
                  this.updateBody(target.value);
              }}
              maxLength="9999"
            />
            {emailFooter && (
              <div
                className="EmailEditor-footer"
                dangerouslySetInnerHTML={{ __html: this.parse(emailFooter) }}
              />
            )}
          </div>
        </FormGroup>
      </div>
    );
  }
}
