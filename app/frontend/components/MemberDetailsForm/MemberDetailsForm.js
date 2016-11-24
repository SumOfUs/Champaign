// @flow
import React, { Component } from 'react';
import Select from 'react-select';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import sortBy from 'lodash/sortBy';
import mapValues from 'lodash/mapValues';
import countryData from 'country-data/data/countries.json';
import Button from '../Button/Button';
import SweetInput from '../SweetInput/SweetInput';
import { updateUser } from '../../state/fundraiser/actions';
// import isEmail from 'validator/lib/isEmail';

import 'react-select/dist/react-select.css';

type ConnectedState = { user: FundraiserFormMember; formId: number; };
type ConnectedDispatch = { updateUser: (u: FundraiserFormMember) => void; };
type OwnProps = {
  buttonText?: React$Element<any> | string;
  proceed?: () => void;
  fields: Object;
  outstandingFields: any[];
  formId: number;
};

export class MemberDetailsForm extends Component {
  props: OwnProps & ConnectedDispatch & ConnectedState;

  state: {
    errors: any;
    loading: boolean;
  };

  static title = <FormattedMessage id="details" defaultMessage="details" />;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      errors: {},
      loading: false,
    };
  }

  isValid(): boolean {
    return !!(this.props.user.email );
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

  prefill(field) {
    // this is where the prefill logic will live
    return field.default_value;
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
      body: JSON.stringify({ ...this.props.user, form_id: this.props.formId }),
    }).then(response => {
      this.setState({ loading: false });
      if (response.ok) {
        return response.json().then(this.handleSuccess.bind(this));
      }
      return response.json().then(this.handleFailure.bind(this));
    }).catch(() => this.setState({ loading: false }));
  }

  update(a, b) {
    // this is clearly broken
    const { user, updateUser } = this.props;
    let newFields = {...user};
    newFields[a] = b;
    console.log(newFields);
    updateUser(newFields);
  }

  smallInput(field) {
    let type = 'text';
    if (field.data_type === 'phone') type = 'tel';
    if (field.data_type === 'email') type = 'email';
    return (<SweetInput
              name={field.name}
              type={type}
              value={field.default_value}
              required={field.required}
              errorMessage={this.getFieldError('email')}
              label={field.label}
              onChange={val => this.update(field.name, val)}
            />);
  }
  render() {
    const { user, updateUser } = this.props;
    const { loading } = this.state;

    return (
      <div className="MemberDetailsForm-root">
        <form
          onSubmit={this.submit.bind(this)}
          className="form--big action-form">
          {this.props.fields.map((field, ii) => {
            let inner;
            switch (field.data_type) {
              case 'text':
              case 'postal':
              case 'phone':
              case 'email':
                inner = this.smallInput(field);
                break;
              case 'hidden':
                inner = this.hiddenInput(field);
                break;
              case 'paragraph':
                inner = this.textArea(field);
                break;
              case 'checkbox':
                inner = this.checkbox(field);
                break;
              case 'country':
                inner = this.countryDropdown(field);
                break;
              case 'dropdown':
                inner = this.dropdown(field);
                break;
              case 'choice':
                inner = this.choice(field);
                break;
              case 'instruction':
                inner = this.instruction(field);
                break;
            }
            return (
              <div key={`MemberDetailsForm-field-${field.name}`} className="MemberDetailsForm-field form__group action-form__field-container">
                { inner }
              </div>
            );
          })}


          <Button
            type="submit"
            disabled={!this.isValid() || loading }
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
