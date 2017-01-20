// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import FieldShape from '../../components/FieldShape/FieldShape';
import type { Country, Target } from '../../containers/CallToolView/CallToolView';
import type { Field } from '../../components/FieldShape/FieldShape';

type OwnProps = {
  targetCountries: Country[];
  targets: Target[];
  selectedTarget: Target;
  form: {
    memberPhoneNumber?: string;
    countryCode?: string;
  };
  errors: {
    memberPhoneNumber?: string;
    countryCode?: string;
  };
  onCountryCodeChange: (v?: string) => void;
  onMemberPhoneNumberChange: (v?: string) => void;
  onSubmit: (any) => void;
  loading: boolean;
}

const memberPhoneNumberField: Field = {
  data_type: 'text',
  name: 'call_tool[member_phone_number]',
  label: <FormattedMessage id='call_tool.form.phone_number' />,
  default_value: '',
  required: true,
  disabled: false
};

const countryCodeField:Field = {
  data_type: 'select',
  name: 'call_tool[country_code]',
  label: <FormattedMessage id='call_tool.form.country' />,
  default_value: null,
  required: true,
  disabled: false,
  choices: []
};


class Form extends Component {
  props: OwnProps;
  fields: { [key: string]: Field };

  constructor(props: OwnProps) {
    super(props);

    this.fields = {
      memberPhoneNumberField: memberPhoneNumberField,
      countryCodeField: Object.assign({}, countryCodeField, { choices: this.countryCodeOptions() })
    };
  }

  countryCodeOptions() {
    return this.props.targetCountries.map((country) => {
      return { value: country.code, label: country.name };
    });
  }

  render() {
    return(
      <form className='action-form form--big' data-remote="true" >
        <FieldShape
          key="memberPhoneNumber"
          errorMessage={this.props.errors.memberPhoneNumber}
          onChange={this.props.onMemberPhoneNumberChange}
          value={this.props.form.memberPhoneNumber}
          field={this.fields.memberPhoneNumberField}
        />

        <FieldShape
          key="countryCode"
          errorMessage={this.props.errors.countryCode}
          onChange={this.props.onCountryCodeChange}
          value={this.props.form.countryCode}
          field={this.fields.countryCodeField}
        />

        { !_.isEmpty(this.props.selectedTarget) &&
          <div className="action-form__target form__instruction">
            <p>
              <strong> Target: </strong>
              <span> {this.props.selectedTarget.name}, {this.props.selectedTarget.title} </span>
            </p>
          </div>
        }

        <button
        type="submit"
        onClick={this.props.onSubmit}
        className="button action-form__submit-button"
        disabled={ this.props.loading ? 'disabled' : '' }>
          <FormattedMessage id="call_tool.form.submit" />
        </button>
      </form>
    );
  }
}

export default Form;
