// @flow
import React, { PureComponent } from 'react';
import Input from '../SweetInput/SweetInput';
import FormGroup from '../Form/FormGroup';
import ErrorMessage from '../ErrorMessage';
import { FormattedMessage } from 'react-intl';
import { compact, get, template } from 'lodash';
import type { ErrorMap } from '../../util/ChampaignClient/Base';
import './EmailEditor.scss';

export type EmailProps = {
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
  onUpdate: (email: EmailProps) => void,
};

export default class EmailEditor extends PureComponent {
  props: Props;
  state: EmailProps;
  constructor(props: Props) {
    super(props);
    this.state = {
      subject: this.props.emailSubject,
      body: this.props.emailBody,
    };
  }

  componentDidMount() {
    this.update();
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

  update = () => {
    if (typeof this.props.onUpdate === 'function') {
      this.props.onUpdate({
        subject: this.state.subject,
        body: this.body(),
      });
    }
  };

  updateSubject = (subject: string) => {
    this.setState(s => ({ ...s, subject }), this.update);
  };

  updateBody = ({ target }: SyntheticEvent) => {
    if (target instanceof HTMLTextAreaElement) {
      const body = target.value;
      this.setState(s => ({ ...s, body }), this.update);
    }
  };

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
            onChange={this.updateSubject}
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
              defaultValue={this.state.body}
              onChange={this.updateBody}
              maxLength="9999"
            />
            {emailFooter && (
              <div
                className="EmailEditor-footer"
                dangerouslySetInnerHTML={{ __html: this.parse(emailFooter) }}
              />
            )}
          </div>

          <ErrorMessage name="Email body" error={this.props.errors.body} />
        </FormGroup>
      </div>
    );
  }
}
