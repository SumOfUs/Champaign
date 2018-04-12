// @flow
import React, { Component } from 'react';
import Input from '../SweetInput/SweetInput';
import FormGroup from '../Form/FormGroup';
import ErrorMessages from '../ErrorMessages';
import { FormattedMessage } from 'react-intl';
import { compact, debounce, get, template, isEqual } from 'lodash';
import classnames from 'classnames';
import type { ErrorMap } from '../../util/ChampaignClient/Base';
import {
  ContentState,
  CompositeDecorator,
  convertFromHTML,
  Editor,
  EditorState,
} from 'draft-js';
import { stateFromHTML } from 'draft-js-import-html';
import { stateToHTML } from 'draft-js-export-html';
import './EmailEditor.scss';

export type EmailProps = {
  subject: string,
  body: string,
  emailBody: string,
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

type State = {
  subject: string,
  header: string,
  footer: string,
  editorState: EditorState,
};

function interpolateVars(templateString: ?string, templateVars: any): string {
  if (!templateString) return '';
  return template(templateString)(templateVars);
}
export default class EmailEditor extends Component {
  props: Props;
  state: State;
  constructor(props: Props) {
    super(props);

    this.state = EmailEditor.getDerivedStateFromProps(props);
  }

  static getDerivedStateFromProps(props: Props): State {
    return {
      subject: interpolateVars(props.subject, props.templateVars),
      header: interpolateVars(props.header, props.templateVars),
      footer: interpolateVars(props.footer, props.templateVars),
      editorState: EditorState.createWithContent(
        stateFromHTML(interpolateVars(props.body, props.templateVars))
      ),
    };
  }

  componentDidMount() {
    this.update();
  }

  componentDidUpdate() {
    this.update();
  }

  shouldComponentUpdate(nextProps: Props, nextState: State) {
    return (
      !isEqual(nextProps.templateVars, this.props.templateVars) ||
      this.state.editorState !== nextState.editorState
    );
  }

  body() {
    return compact([
      this.parse(this.props.header),
      this.interpolateVars(
        stateToHTML(this.state.editorState.getCurrentContent())
      ),
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

  update = debounce(() => {
    if (typeof this.props.onUpdate === 'function') {
      this.props.onUpdate({
        subject: this.state.subject,
        body: this.body(),
      });
    }
  }, 400);

  updateSubject = (subject: string) => {
    this.setState(s => ({ ...s, subject }), this.update);
  };

  onEditorChange = (editorState: EditorState) => {
    this.setState({ editorState }, this.update);
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
              <Editor
                editorState={this.state.editorState}
                onChange={this.onEditorChange}
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
