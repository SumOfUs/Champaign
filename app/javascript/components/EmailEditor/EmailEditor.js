// @flow
import React, { Component } from 'react';
import Input from '../SweetInput/SweetInput';
import FormGroup from '../Form/FormGroup';
import ErrorMessages from '../ErrorMessages';
import { FormattedMessage } from 'react-intl';
import { compact, get, template, isEqual } from 'lodash';
import classnames from 'classnames';
import type { ErrorMap } from '../../util/ChampaignClient/Base';
import './EmailEditor.scss';

export type EmailProps = {
  subject: string,
  body: string,
};

type Props = {
  body: string,
  footer?: string,
  header?: string,
  subject: string,
  templateVars: { [key: string]: any },
  errors: ErrorMap,
  onUpdate: (email: EmailProps) => void,
};

export default class EmailEditor extends Component {
  props: Props;
  state: EmailProps;
  constructor(props: Props) {
    super(props);
    this.state = {
      subject: this.interpolateVars(this.props.subject),
      body: this.interpolateVars(this.props.body),
    };
  }

  componentDidMount() {
    this.update();
  }

  componentDidUpdate() {
    this.update();
  }

  shouldComponentUpdate(nextProps: Props) {
    return !isEqual(nextProps, this.props);
  }

  body() {
    return compact([
      this.parse(this.props.header),
      this.state.body,
      this.parse(this.props.footer),
    ]).join('\n\n');
  }

  parse(templateString?: string = ''): string {
    if (!templateString) return '';
    templateString = templateString.replace(/(?:\r\n|\r|\n)/g, '<br />');
    return this.interpolateVars(templateString);
  }

  interpolateVars(templateString?: string = ''): string {
    if (!templateString) return '';
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
    const { header, footer, errors } = this.props;

    const bodyClassName = classnames({
      'has-error': errors.body && errors.body.length > 0,
    });
    return (
      <div className="EmailEditor">
        <FormGroup>
          <Input
            name="subject"
            value={this.state.subject}
            hasError={errors.subject && errors.subject.length}
            label={
              <FormattedMessage
                id="email_tool.form.subject"
                defaultMessage="Subject (default)"
              />
            }
            onChange={this.updateSubject}
          />
          <ErrorMessages
            name={<FormattedMessage id="email_tool.form.subject" />}
            errors={errors.subject}
          />
        </FormGroup>
        <FormGroup>
          <FormGroup className={bodyClassName}>
            <div className="EmailEditor-body">
              {header && (
                <div
                  className="EmailEditor-header"
                  dangerouslySetInnerHTML={{ __html: this.parse(header) }}
                />
              )}
              <textarea
                name="email_body"
                defaultValue={this.state.body}
                onChange={this.updateBody}
                maxLength="9999"
              />
              {footer && (
                <div
                  className="EmailEditor-footer"
                  dangerouslySetInnerHTML={{ __html: this.parse(footer) }}
                />
              )}
            </div>
          </FormGroup>
          <ErrorMessages
            name={<FormattedMessage id="email_tool.form.email_body" />}
            errors={errors.body}
          />
        </FormGroup>
      </div>
    );
  }
}
