import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import ChampaignAPI from '../../util/ChampaignAPI';
import type { operationResponse } from '../../util/ChampaignAPI';

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

export class CallToolView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      form: {
        memberPhoneNumber: props.memberPhoneNumber,
        countryCode: props.countryCode
      },
      errors: {
        memberPhoneNumber: null,
        countryCode: null,
        base: []
      },
      loading: false,
      selectedTarget: null
    };

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

  getFieldError(field: string): FormattedMessage | void {
    return this.state.errors[field];
  }

  updateCountryCode(countryCode) {
    this.setState({
      form: Object.assign({}, this.state.form, {countryCode: countryCode}),
      selectedTarget: this.selectNewTarget(countryCode),
      errors: Object.assign({}, this.state.errors, { countryCode: null })
    });
  }

  updateMemberPhoneNumber(memberPhoneNumber) {
    this.setState({
      form: Object.assign({}, this.state.form, {memberPhoneNumber: memberPhoneNumber}),
      errors: Object.assign({}, this.state.errors, { memberPhoneNumber: null })
    });
  }

  selectNewTarget(countryCode) {
    const candidates = _.filter(this.props.targets, t => { return t.countryCode === countryCode; });
    return _.sample(candidates);
  }

  selectedTargetIndex() {
    return _.findIndex(this.state.targets, this.state.selectedTarget);
  }

  submit(event) {
    event.preventDefault();
    if(!this.validateForm()) return;
    this.setState({ loading: true });
    ChampaignAPI.calls.create({
      pageId: this.props.pageId,
      memberPhoneNumber: this.state.form.memberPhoneNumber,
      targetIndex: this.selectedTargetIndex()
    }).then(this.submitSuccessful.bind(this), this.submitFailed.bind(this));
  }

  validateForm() {
    const newErrors = {};
    if(_.isEmpty(this.state.form.memberPhoneNumber)) {
      newErrors.memberPhoneNumber = <FormattedMessage id="validation.is_required" />;
    }

    if(_.isEmpty(this.state.form.countryCode)) {
      newErrors.countryCode = <FormattedMessage id="validation.is_required" />;
    }

    this.setState({
      errors: Object.assign({}, this.state.errors, newErrors)
    });

    return _.isEmpty(newErrors);
  }

  submitSuccessful(response:operationResponse) {
    this.setState({errors: {}, loading: false});
  }

  submitFailed(response:operationResponse) {
    const newErrors = Object.assign({}, this.state.errors);
    if(!_.isEmpty(response.errors.memberPhoneNumber)) {
      newErrors.memberPhoneNumber = response.errors.memberPhoneNumber[0];
    }

    if(!_.isEmpty(response.errors.base)) {
      newErrors.base = response.errors.base;
    }
    this.setState({errors: newErrors, loading: false});
  }

  render() {
    return (
      <div>
        <h1> { this.props.title } </h1>

        { !_.isEmpty(this.state.errors) &&
          <ul>
            { this.state.errors.base.map((error, index) => {
                return <li key={`error-${index}`}> {error} </li>;
              })
            }
          </ul>
        }

        <form className='action-form form--big' data-remote="true" >
          <FieldShape
          key="memberPhoneNumber"
          errorMessage={this.getFieldError("memberPhoneNumber")}
          onChange={this.updateMemberPhoneNumber.bind(this)}
          value={this.state.form.memberPhoneNumber}
          field={this.fields.memberPhoneNumberField} />

          <FieldShape
          key="countryCode"
          errorMessage={this.getFieldError("countryCode")}
          onChange={this.updateCountryCode.bind(this)}
          value={this.state.form.countryCode}
          field={this.fields.countryCodeField} />

          { !_.isEmpty(this.state.selectedTarget) &&
            <div className="action-form__target form__instruction">
              <p>
                <strong> Target: </strong>
                <span> {this.state.selectedTarget.name}, {this.state.selectedTarget.title} </span>
              </p>
            </div>
          }

          <button onClick={this.submit.bind(this)} type="submit" className="button action-form__submit-button">{ "Submit" }</button>
        </form>
      </div>
    );
  }
}

CallToolView.propTypes = {
  title: React.PropTypes.string.isRequired,
  pageId: React.PropTypes.string.isRequired,
  targets: React.PropTypes.arrayOf(
    React.PropTypes.shape({
      countryCode: React.PropTypes.string.isRequired,
      name:        React.PropTypes.string.isRequired,
      title:       React.PropTypes.string.isRequired
    })
  ),
  targetCountries: React.PropTypes.arrayOf(
    React.PropTypes.shape({
      code: React.PropTypes.string.isRequired,
      name: React.PropTypes.string.isRequired
    })
  )
};

export default CallToolView;

