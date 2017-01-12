import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import FieldShape from '../../components/FieldShape/FieldShape';

const memberPhoneNumberField = {
  data_type: 'text',
  name: 'call_tool[member_phone_number]',
  label: <FormattedMessage id='call_tool.form.phone_number' />,
  default_value: '',
  required: true,
  disabled: false
};

const countryCodeField = {
  data_type: 'select',
  name: 'call_tool[country_code]',
  label: <FormattedMessage id='call_tool.form.country' />,
  default_value: null,
  required: true,
  disabled: false,
  choices: []
};

class Form extends Component {

  constructor(props) {
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
        field={this.fields.memberPhoneNumberField} />

        <FieldShape
        key="countryCode"
        errorMessage={this.props.errors.countryCode}
        onChange={this.props.onCountryCodeChange}
        value={this.props.form.countryCode}
        field={this.fields.countryCodeField} />

        { !_.isEmpty(this.props.selectedTarget) &&
          <div className="action-form__target form__instruction">
            <p>
              <strong> Target: </strong>
              <span> {this.props.selectedTarget.name}, {this.props.selectedTarget.title} </span>
            </p>
          </div>
        }

        <button onClick={this.props.onSubmit} type="submit" className="button action-form__submit-button">
          <FormattedMessage id="call_tool.form.submit" />
        </button>
      </form>
    );
  }
}

const types = React.PropTypes;

const targetShape = types.shape({
  countryCode: types.string.isRequired,
  name:        types.string.isRequired,
  title:       types.string.isRequired
});

Form.propTypes = {
  targetCountries: types.arrayOf(
    types.shape({
      code: types.string.isRequired,
      name: types.string.isRequired
    })
  ),
  targets: types.arrayOf(targetShape),
  selectedTarget: targetShape,
  form: types.shape({
    memberPhoneNumber: types.string,
    countryCode:       types.string
  }),
  errors: types.shape({
    memberPhoneNumber: types.oneOfType([types.string, types.element]),
    countryCode: types.oneOfType([types.string, types.element])
  }),
  onCountryCodeChange: types.func.isRequired,
  onMemberPhoneNumberChange: types.func.isRequired,
  onSubmit: types.func.isRequired
};

export default Form;
