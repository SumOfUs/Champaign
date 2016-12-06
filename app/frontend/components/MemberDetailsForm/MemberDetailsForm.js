// @flow weak
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import mapValues from 'lodash/mapValues';
import Button from '../Button/Button';
import { updateUser } from '../../state/fundraiser/actions';
import FieldShape from '../FieldShape/FieldShape';

import 'react-select/dist/react-select.css';

type ConnectedState = { user: FundraiserFormMember; formId: number; };
type ConnectedDispatch = { updateUser: (u: FundraiserFormMember) => void; };
type OwnProps = {
  buttonText?: React$Element<any> | string;
  proceed?: () => void;
  fields: Object;
  prefillValues: Object;
  outstandingFields: any[];
  formId: number;
};

export class MemberDetailsForm extends Component {
  props: OwnProps & ConnectedDispatch & ConnectedState;

  state: {
    errors: any;
    loading: boolean;
    formValues: any;
  };

  static title = <FormattedMessage id="details" defaultMessage="details" />;

  HIDDEN_FIELDS = ['source', 'akid', 'referrer_id', 'bucket'];

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      errors: {},
      loading: false,
      formValues: this.prefill(),
    };
  }

  isValid(): boolean {
    return !!(this.props.user.email );
  }

  prefill() {
    const formValues = {};
    for (const field of this.props.fields) {
      formValues[field.name] = this.props.prefillValues[field.name] || field.default_value;
    }
    for (const fieldName of this.HIDDEN_FIELDS) {
      if (this.props.prefillValues[fieldName]) {
        formValues[fieldName] = this.props.prefillValues[fieldName];
      }
    }
    return formValues;
  }

  getFieldError(field: string): FormattedMessage | void {
    const error = this.state.errors[field];
    if (!error) return null;
    return <FormattedMessage {...error} />;
  }

  buttonText() {
    if (this.state.loading) {
      return <FormattedMessage id="validating" defaultMessage={I18n.t('form.processing')} />;
    } else if (this.props.buttonText) {
      return this.props.buttonText;
    } else {
      return <FormattedMessage id="submit" defaultMessage={I18n.t('form.submit')} />;
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
        id: 'field_error_message',
        defaultMessage: 'This field {message}',
        values: { message }
      };
    });

    this.setState({ errors });
  }

  updateField(key, value) {
    const vals = this.state.formValues;
    vals[key] = value;
    this.setState({formValues: vals});
  }

  submit(e: SyntheticEvent) {
    this.setState({ loading: true });
    e.preventDefault();
    // HACKISH
    // Use a proper xhr lib if we want to make our lives easy.
    // Ideally a
    fetch(`/api/pages/${this.props.formId}/actions/validate`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        accept: 'application/json',
      },
      body: JSON.stringify({ ...this.state.formValues, form_id: this.props.formId }),
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
              value={this.state.formValues[field.name]}
              field={field} />
          )}

          <Button
            type="submit"
            disabled={ loading }
            onClick={this.submit.bind(this)}>
            {this.buttonText()}
          </Button>
        </form>
      </div>
    );
  }
}

const mapStateToProps = (state: AppState): ConnectedState => ({
  formId: state.fundraiser.formId,
  user: state.fundraiser.user,
});

const mapDispatchToProps = (dispatch: Dispatch): ConnectedDispatch => ({
  updateUser: (user: FundraiserFormMember) => dispatch(updateUser(user)),
});

export default connect(mapStateToProps, mapDispatchToProps)(MemberDetailsForm);
