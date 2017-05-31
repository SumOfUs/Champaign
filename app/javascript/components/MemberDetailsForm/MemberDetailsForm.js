// @flow weak
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import mapValues from 'lodash/mapValues';
import Button from '../Button/Button';
import { updateForm } from '../../state/fundraiser/actions';
import FieldShape from '../FieldShape/FieldShape';

import type { Element } from 'react';
import type { Dispatch } from 'redux';
import type { AppState } from '../../state';

import 'react-select/dist/react-select.css';

type OwnProps = {
  buttonText?: Element<any> | string;
  proceed?: () => void;
  fields: Object;
  prefillValues: Object;
  outstandingFields: any[];
  pageId: number;
  formId: number;
  form: Object;
  formId: number;
  updateForm: (form: Object) => void;
};

export class MemberDetailsForm extends Component {
  props: OwnProps & $Shape<mapStateToProps>;

  state: {
    errors: any;
    loading: boolean;
  };

  static title = <FormattedMessage id="details" defaultMessage="details" />;

  HIDDEN_FIELDS = ['source', 'akid', 'referrer_id', 'bucket', 'referring_akid'];

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      errors: {},
      loading: false,
    };
  }

  componentDidMount() {
    this.prefill();
  }

  getPrefillValue(name) {
    if (!this.props.prefillValues) return null;

    return this.props.prefillValues[name];
  }

  prefill() {
    const data = {};
    for (const field of this.props.fields) {
      data[field.name] = this.getPrefillValue(field.name) || field.default_value;
    }

    for (const name of this.HIDDEN_FIELDS) {
      if (this.getPrefillValue(name)) {
        data[name] = this.props.prefillValues[name];
      }
    }
    this.props.updateForm({...this.props.form, ...data});
  }

  getFieldError(field: string): FormattedMessage | void {
    const error = this.state.errors[field];
    if (!error) return null;
    return <FormattedMessage {...error} />;
  }

  buttonText() {
    if (this.state.loading) {
      return <FormattedMessage id="form.processing" defaultMessage="Processing..." />;
    } else if (this.props.buttonText) {
      return this.props.buttonText;
    } else {
      return <FormattedMessage id="form.submit" defaultMessage="Submit" />;
    }
  }

  handleSuccess() {
    this.setState({ errors: {} }, () => {
      if (this.props.proceed) {
        this.props.proceed();
      }
    });
  }

  handleFailure(response: any) {
    const errors = mapValues(response.errors, ([message]) => {
      return {
        id: 'errors.this_field_with_message',
        defaultMessage: 'This field {message}',
        values: { message }
      };
    });

    this.setState({ errors });
  }

  updateField(key, value) {
    this.props.updateForm({
      ...this.props.form,
      [key]: value,
    });
  }

  submit(e: SyntheticEvent) {
    this.setState({ loading: true });
    e.preventDefault();
    // HACKISH
    // Use a proper xhr lib if we want to make our lives easy.
    // Ideally a
    fetch(`/api/pages/${this.props.pageId}/actions/validate`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        accept: 'application/json',
      },
      body: JSON.stringify({ ...this.props.form, form_id: this.props.formId }),
    }).then(response => {
      this.setState({ loading: false });
      if (response.ok) {
        return response.json().then(this.handleSuccess.bind(this));
      }
      return response.json().then(this.handleFailure.bind(this));
    }, failure => {
      this.setState({ loading: false });
    });
  }

  render() {
    const { loading } = this.state;

    return (
      <div className="MemberDetailsForm-root">
        <form onSubmit={this.submit.bind(this)} className="form--big action-form">
          {this.props.fields.map((field, ii) =>
            <FieldShape
              key={field.name}
              errorMessage={this.getFieldError(field.name)}
              onChange={(value) => this.updateField(field.name, value)}
              value={this.props.form[field.name]}
              field={field} />
          )}

          <Button
            type="submit"
            disabled={ loading }
            className='action-form__submit-button'
            onClick={this.submit.bind(this)}>
            {this.buttonText()}
          </Button>
        </form>
      </div>
    );
  }
}

const mapStateToProps = (state: AppState) => ({
  formId: state.fundraiser.formId,
  form: state.fundraiser.form,
});

const mapDispatchToProps = (dispatch: Dispatch<*>) => ({
  updateForm: (form: Object) => dispatch(updateForm(form)),
});

export default connect(mapStateToProps, mapDispatchToProps)(MemberDetailsForm);
