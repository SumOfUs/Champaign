//  weak
import React, { Component } from 'react';
import Input from '../SweetInput/SweetInput';
import FormGroup from '../Form/FormGroup';
import ErrorMessages from '../ErrorMessages';
import { FormattedMessage } from 'react-intl';
import { compact, debounce, template, isEqual } from 'lodash';
import classnames from 'classnames';
import { Editor, EditorState } from 'draft-js';
import { stateFromHTML } from 'draft-js-import-html';
import { stateToHTML } from 'draft-js-export-html';
import './EmailEditor.scss';

const MAX_SUBJECT_LENGTH = 64;

export default class EmailEditor extends Component {
  constructor(props) {
    super(props);
    const fn = this.props.templateInterpolate || interpolateVars;

    this.state = {
      subject: interpolateVars(props.subject, props.templateVars),
      editorState: EditorState.createWithContent(
        stateFromHTML(fn(props.body, props.templateVars))
      ),
    };
  }

  static getDerivedStateFromProps(props, state) {
    const fn = props.templateInterpolate;
    let body = props.body;

    if (typeof fn == 'function') {
      body = fn(props.body, props.templateVars);
    }

    return {
      header: interpolateVars(props.header, props.templateVars),
      body,
      footer: interpolateVars(props.footer, props.templateVars),
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    return (
      !isEqual(nextProps.templateVars, this.props.templateVars) ||
      this.state.subject !== nextState.subject ||
      this.state.editorState !== nextState.editorState ||
      !isEqual(this.props.errors, nextProps.errors)
    );
  }

  componentDidMount() {
    this.update();
    this.checkHeaderFooter();
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

  updateSubject = subject => {
    if (subject.length > MAX_SUBJECT_LENGTH) return;
    this.setState({ subject }, this.update);
  };

  onEditorChange = editorState => {
    this.setState({ editorState }, () => {
      if (!editorState.getLastChangeType()) return;
      this.update();
    });
  };

  checkHeaderFooter = () => {
    if (this.props.header && this.props.footer) {
      if ($(this.props.header)[0].innerText.trim().length === 0) {
        $('.EmailEditor-header').css('display', 'none');
      }
      if ($(this.props.footer)[0].innerText.trim().length === 0) {
        $('.EmailEditor-footer').css('display', 'none');
      }
    }
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

function interpolateVars(templateString, templateVars) {
  if (!templateString) return '';
  return template(templateString)(templateVars);
}
