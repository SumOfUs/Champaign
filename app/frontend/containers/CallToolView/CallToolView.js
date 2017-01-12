// @flow weak

import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import ChampaignAPI from '../../util/ChampaignAPI';
import type { operationResponse } from '../../util/ChampaignAPI';

import Form from '../../components/CallTool/Form';

type OwnState = {
  form: {
    memberPhoneNumber?: string;
    countryCode?: string;
  };
  errors: {
    memberPhoneNumber?: any;
    countryCode?: any;
    base?: any[];
  };
  loading: boolean;
  selectedTarget?: {
    countryCode: string,
    name: string,
    title: string
  };
}

class CallToolView extends Component {
  state: OwnState;

  constructor(props) {
    super(props);
    this.state = {
      form: {},
      errors: {},
      loading: false
    };
  }

  countryCodeChanged(countryCode) {
    this.setState({
      form: Object.assign({}, this.state.form, {countryCode: countryCode}),
      selectedTarget: this.selectNewTarget(countryCode),
      errors: Object.assign({}, this.state.errors, { countryCode: null })
    });
  }

  memberPhoneNumberChanged(memberPhoneNumber) {
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
    return _.findIndex(this.props.targets, this.state.selectedTarget);
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

        { !_.isEmpty(this.state.errors.base) &&
          <ul>
            { this.state.errors.base.map((error, index) => {
                return <li key={`error-${index}`}> {error} </li>;
              })
            }
          </ul>
        }
        <Form
          targetCountries={this.props.targetCountries}
          targets={this.props.targets}
          selectedTarget={this.state.selectedTarget}
          form={this.state.form}
          errors={this.state.errors}
          onCountryCodeChange={this.countryCodeChanged.bind(this)}
          onMemberPhoneNumberChange={this.memberPhoneNumberChanged.bind(this)}
          onSubmit={this.submit.bind(this)}
        />
      </div>
    );
  }
}

const types = React.PropTypes;

CallToolView.propTypes = {
  memberPhoneNumber: types.string,
  countryCode: types.string,
  title: types.string.isRequired,
  pageId: types.string.isRequired,
  targets: types.arrayOf(
    types.shape({
      countryCode: types.string.isRequired,
      name:        types.string.isRequired,
      title:       types.string.isRequired
    })
  ),
  targetCountries: types.arrayOf(
    types.shape({
      code: types.string.isRequired,
      name: types.string.isRequired
    })
  )
};

export default CallToolView;

