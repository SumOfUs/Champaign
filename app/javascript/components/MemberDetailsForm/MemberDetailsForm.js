//  weak
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import _ from 'lodash';
import Button from '../Button/Button';
import { updateForm } from '../../state/fundraiser/actions';
import FieldShape from '../FieldShape/FieldShape';
import ee from '../../shared/pub_sub';

export class MemberDetailsForm extends Component {
  static title = <FormattedMessage id="details" defaultMessage="details" />;

  HIDDEN_FIELDS = [
    'source',
    'akid',
    'referrer_id',
    'rid',
    'bucket',
    'referring_akid',
  ];

  constructor(props) {
    super(props);

    this.state = {
      errors: {},
      loading: false,
    };
  }

  componentDidMount() {
    this.prefill();
  }

  prefill() {
    const data = {};
    for (const field of this.props.fields) {
      data[field.name] = this.props.formValues[field.name]
        ? this.props.formValues[field.name]
        : field.default_value;
    }

    for (const name of this.HIDDEN_FIELDS) {
      if (this.props.formValues[name]) {
        data[name] = this.props.formValues[name];
      }
    }
    this.props.updateForm({ ...this.props.form, ...data });
  }

  getFieldError(field) {
    const error = this.state.errors[field];
    if (!error) return null;
    return <FormattedMessage {...error} />;
  }

  buttonText() {
    if (this.state.loading) {
      return (
        <FormattedMessage id="form.processing" defaultMessage="Processing..." />
      );
    } else if (this.props.buttonText) {
      return this.props.buttonText;
    } else {
      return <FormattedMessage id="form.submit" defaultMessage="Submit" />;
    }
  }

  handleSuccess() {
    ee.emit('fundraiser:form:success');
    this.setState({ errors: {} }, () => {
      if (this.props.proceed) {
        this.props.proceed();
      }
    });
  }

  handleFailure(response) {
    ee.emit('fundraiser:form:error', response);
    const errors = _.mapValues(response.errors, ([message]) => {
      return {
        id: 'errors.this_field_with_message',
        defaultMessage: 'This field {message}',
        values: { message },
      };
    });

    this.setState({ errors });
  }

  updateField(key, value) {
    this.state.errors[key] = null; // reset error message when field value changes
    this.props.updateForm({
      ...this.props.form,
      [key]: value,
    });
  }

  submit(e) {
    this.setState({ loading: true });
    e.preventDefault();
    // TODO
    // Use a proper xhr lib if we want to make our lives easy.
    fetch(`/api/pages/${this.props.pageId}/actions/validate`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        accept: 'application/json',
      },
      body: JSON.stringify({ ...this.props.form, form_id: this.props.formId }),
    }).then(
      response => {
        this.setState({ loading: false });
        if (response.ok) {
          return response.json().then(this.handleSuccess.bind(this));
        }
        return response.json().then(this.handleFailure.bind(this));
      },
      failure => {
        this.setState({ loading: false });
      }
    );
  }

  fieldsToDisplay() {
    return this.props.fields.filter(field => {
      switch (field.display_mode) {
        case 'all_members':
          return true;
        case 'recognized_members_only':
          return this.recognizedMemberPresent();
        case 'new_members_only':
          return !this.recognizedMemberPresent();
        default:
          console.log(
            `Unknown display_mode "${field.display_mode}" for field "${field.name}"`
          );
          return false;
      }
    });
  }

  recognizedMemberPresent() {
    return !!this.props.formValues.email;
  }

  render() {
    const { loading } = this.state;

    return (
      <div className="MemberDetailsForm-root">
        <form
          onSubmit={this.submit.bind(this)}
          className="form--big action-form"
        >
          {this.fieldsToDisplay().map(field => (
            <FieldShape
              key={field.name}
              errorMessage={this.getFieldError(field.name)}
              onChange={value => this.updateField(field.name, value)}
              value={this.props.form[field.name]}
              field={field}
            />
          ))}

          <Button
            type="submit"
            disabled={loading}
            className="action-form__submit-button"
          >
            {this.buttonText()}
          </Button>
        </form>
      </div>
    );
  }
}

const mapStateToProps = state => ({
  formId: state.fundraiser.formId,
  form: state.fundraiser.form,
});

const mapDispatchToProps = dispatch => ({
  updateForm: form => dispatch(updateForm(form)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(MemberDetailsForm);
