// @flow
import React, { Component } from 'react';
import Input from '../SweetInput/SweetInput';
import FormGroup from '../Form/FormGroup';
import ErrorMessages from '../ErrorMessages';
import { FormattedMessage } from 'react-intl';
import { compact, debounce, template, isEqual } from 'lodash';
import classnames from 'classnames';
import type { ErrorMap } from '../../util/ChampaignClient/Base';
import { Editor, EditorState } from 'draft-js';
import { stateFromHTML } from 'draft-js-import-html';
import { stateToHTML } from 'draft-js-export-html';
import './EmailEditor.scss';

const MAX_SUBJECT_LENGTH = 64;

export default class EmailEditor extends Component {
  props: Props;
  state: State;
  constructor(props: Props) {
    super(props);

    this.state = {
      subject: interpolateVars(props.subject, props.templateVars),
      editorState: EditorState.createWithContent(
        stateFromHTML(interpolateVars(props.body, props.templateVars))
      ),
    };
  }

  static getDerivedStateFromProps(props: Props, state?: State) {
    return {
      header: interpolateVars(props.header, props.templateVars),
      footer: interpolateVars(props.footer, props.templateVars),
    };
  }

  shouldComponentUpdate(nextProps: Props, nextState: State) {
    return (
      !isEqual(nextProps.templateVars, this.props.templateVars) ||
      this.state.subject !== nextState.subject ||
      this.state.editorState !== nextState.editorState
    );
  }

  componentDidMount() {
    this.update();
  }

  componentDidUpdate() {
    this.update();
  }

  update = debounce(() => {
    if (typeof this.props.onUpdate !== 'function') return;
    this.props.onUpdate({
      subject: this.state.subject,
      body: this.body(),
    });
  }, 400);

  body() {
    return compact([
      this.state.header,
      stateToHTML(this.state.editorState.getCurrentContent()),
      this.state.footer,
    ]).join('');
  }

  updateSubject = (subject: string) => {
    if (subject.length > MAX_SUBJECT_LENGTH) return;
    this.setState({ subject }, this.update);
  };

  onEditorChange = (editorState: EditorState) => {
    this.setState({ editorState }, () => {
      if (!editorState.getLastChangeType()) return;
      this.update();
    });
  };

  // class applied to content blocks
  blockStyleFn = () => 'editor-content-block';

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
                  dangerouslySetInnerHTML={{ __html: this.state.header }}
                />
              )}
              <Editor
                editorState={this.state.editorState}
                onChange={this.onEditorChange}
                blockStyleFn={this.blockStyleFn}
              />
              {footer && (
                <div
                  className="EmailEditor-footer"
                  dangerouslySetInnerHTML={{ __html: this.state.footer }}
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

function interpolateVars(templateString: ?string, templateVars: any): string {
  if (!templateString) return '';
  return template(templateString)(templateVars);
}

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

type State = {
  subject: string,
  editorState: EditorState,
  header?: string,
  footer?: string,
};
