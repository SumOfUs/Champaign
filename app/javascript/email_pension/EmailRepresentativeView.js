import React, { Component } from 'react';
import { isEmpty, find, template, merge, each, pick } from 'lodash';

import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import FormGroup from '../components/Form/FormGroup';
import EmailEditor from '../components/EmailEditor/EmailEditor';
import { FormattedMessage, injectIntl } from 'react-intl';
import './EmailPensionView.scss';

import type { Dispatch } from 'redux';

class SelectTarget extends Component {
  constructor(props) {
    super(props);

    this.state = {
      postcode: '',
      targets: [],
    };
  }

  componentDidMount() {
    this.getTarget('10178');
  }

  getTarget = (postcode: string) => {
    this.setState({ postcode: postcode });

    if (!postcode) return;
    if (postcode.length < 5) return;

    fetch(
      `https://pzeb4jmr4l.execute-api.us-east-1.amazonaws.com/dev/germany/${postcode}`
    )
      .then(resp => resp.json())
      .then(json => {
        this.setState({ targets: json });
        const data = { postcode, targets: json };
        this.props.handler(data);
      });
  };

  renderTarget({ id, title, first_name, last_name }) {
    return (
      <p key={id}>
        {title} {first_name} {last_name}
      </p>
    );
  }

  render() {
    const targets = this.state.targets.map(target => this.renderTarget(target));

    return (
      <div>
        <FormGroup>
          <Input
            name="postcode"
            type="text"
            label="Enter your postcode"
            value={this.state.postcode}
            onChange={value => this.getTarget(value)}
          />
        </FormGroup>
        {targets}
      </div>
    );
  }
}

class EmailRepresentativeView extends Component {
  constructor(props) {
    super(props);

    this.defaultTemplateVars = {
      targets_names: this.props.intl.formatMessage({
        id: 'email_tool.template_defaults.target_full_name',
      }),
      constituency: this.props.intl.formatMessage({
        id: 'email_tool.template_defaults.constituency_name',
      }),
      name: this.props.intl.formatMessage({
        id: 'email_tool.template_defaults.name',
      }),
    };

    this.state = {
      errors: {},
      targets: [],
      name: '',
      email: '',
      subject: '',
      target_name: '',
      target_email: '',
      ...props,
    };
  }

  validateForm() {
    const errors = {};

    const fields = ['subject', 'name', 'email', 'targets'];

    fields.forEach(field => {
      if (isEmpty(this.state[field])) {
        const location = `email_tool.form.errors.${field}`;
        const message = <FormattedMessage id={location} />;
        errors[field] = message;
      }
    });

    this.setState({ errors: errors });
    return isEmpty(errors);
  }

  templateVars() {
    let vars = pick(this.state, ['name', 'email', 'constituency']);

    if (this.state.targets) {
      vars.targets_names = this.state.targets
        .map(
          target => `${target.title} ${target.first_name} ${target.last_name}`
        )
        .join(', ');
    }

    each(this.defaultTemplateVars, (val, key) => {
      if (vars[key] === undefined || vars[key] === '') {
        vars[key] = val;
      }
    });

    return vars;
  }

  onEmailEditorUpdate = ({ subject, body }) => {
    this.setState(state => ({ ...state, body, subject }));
  };

  errorNotice = () => {
    if (!isEmpty(this.state.errors)) {
      return (
        <span className="error-msg left-align">
          <FormattedMessage id="email_tool.form.errors.message" />
        </span>
      );
    }
  };

  onSubmit = e => {
    e.preventDefault();

    const valid = this.validateForm();
    if (!valid) return;

    const payload = {
      body: this.state.body,
      subject: this.state.subject,
      from_name: this.state.name,
      from_email: this.state.email,
      postcode: this.state.postcode,
    };

    merge(payload, this.props.formValues);
    // this.setState({isSubmitting: true});

    // FIXME Handle errors
    $.post(`/api/pages/${this.props.pageId}/pension_emails`, payload);
  };

  handleTargetSelection(data) {
    this.setState({
      constituency: data.targets[0].constituency,
      targets: data.targets,
      postcode: data.postcode,
    });
  }

  render() {
    return (
      <div className="email-target">
        <div className="email-target-form">
          <form onSubmit={this.onSubmit} className="action-form form--big">
            <SelectTarget handler={this.handleTargetSelection.bind(this)} />

            <div className="email-target-action">
              <h3>
                <FormattedMessage
                  id="email_tool.section.compose"
                  defaultMessage="Compose Your Email"
                />
              </h3>

              <FormGroup>
                <Input
                  name="name"
                  label={
                    <FormattedMessage
                      id="email_tool.form.your_name"
                      defaultMessage="Your name (default)"
                    />
                  }
                  value={this.props.name}
                  errorMessage={this.state.errors.name}
                  onChange={value => this.props.changeName(value)}
                />
              </FormGroup>

              <FormGroup>
                <Input
                  name="email"
                  type="email"
                  label={
                    <FormattedMessage
                      id="email_tool.form.your_email"
                      defaultMessage="Your email (default)"
                    />
                  }
                  value={this.props.email}
                  errorMessage={this.state.errors.email}
                  onChange={value => this.props.changeEmail(value)}
                />
              </FormGroup>

              <EmailEditor
                errors={this.state.errors}
                body={this.props.emailBody}
                header={this.props.emailHeader}
                footer={this.props.emailFooter}
                subject={this.props.emailSubject}
                templateVars={this.templateVars()}
                onUpdate={this.onEmailEditorUpdate}
              />
            </div>

            <div className="form__group">
              <Button
                disabled={this.state.isSubmitting}
                className="button action-form__submit-button"
              >
                <FormattedMessage
                  id="email_tool.form.send_email"
                  defaultMessage="Send email (default)"
                />
              </Button>
              {this.errorNotice()}
            </div>
          </form>
        </div>
      </div>
    );
  }
}

export default injectIntl(EmailRepresentativeView);
