import React, { Component } from 'react';
import { isEmpty, find, template, merge, each, pick } from 'lodash';

import Input from '../components/SweetInput/SweetInput';
import Button from '../components/Button/Button';
import FormGroup from '../components/Form/FormGroup';
import EmailEditor from '../components/EmailEditor/EmailEditor';
import SelectTarget from './SelectTarget';
import { FormattedMessage, injectIntl } from 'react-intl';
import './EmailPensionView.scss';

class EmailRepresentativeView extends Component {
  constructor(props) {
    super(props);

    this.handleChange = this.handleChange.bind(this);

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
    console.log(errors);
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

  onSubmission = e => {
    e.preventDefault();

    const valid = this.validateForm();
    if (!valid) return;

    const payload = {
      body: this.state.body,
      subject: this.state.subject,
      from_name: this.state.name,
      from_email: this.state.email,
      postcode: this.state.postcode,
      plugin_id: this.props.pluginId,
    };

    merge(payload, this.props.formValues);
    this.setState({ isSubmitting: true });

    // FIXME Handle errors
    $.post(`/api/pages/${this.props.pageId}/pension_emails`, payload).fail(
      e => {
        console.log('Unable to send email', e);
      }
    );
  };

  handleTargetSelection(data) {
    this.setState({
      constituency: data.targets[0].constituency,
      targets: data.targets,
      postcode: data.postcode,
    });
  }

  handleChange(data) {
    this.setState(data);
  }

  render() {
    return (
      <div className="email-target">
        <div className="email-target-form">
          <form
            onSubmit={e => e.preventDefault()}
            className="action-form form--big"
          >
            <SelectTarget
              handler={this.handleTargetSelection.bind(this)}
              endpoint={this.props.targetEndpoint}
              error={this.state.errors.targets}
            />

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
                  value={this.state.name}
                  errorMessage={this.state.errors.name}
                  onChange={value => {
                    this.handleChange({ name: value });
                  }}
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
                  value={this.state.email}
                  errorMessage={this.state.errors.email}
                  onChange={value => {
                    this.handleChange({ email: value });
                  }}
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
                onClick={this.onSubmission}
                disabled={this.state.isSubmitting}
                type="button"
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
