// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import ChampaignAPI from '../../util/ChampaignAPI';
import type { OperationResponse } from '../../util/ChampaignAPI';

import Form from '../../components/CallTool/Form';

export type Target = {
  countryCode: string;
  name: string;
  title: string;
}

export type Country = {
  code: string;
  name: string;
}

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
  selectedTarget?: Target;
}

type OwnProps = {
  memberPhoneNumber?: string;
  countryCode?: string;
  title?: string;
  pageId: string | number;
  targets: Target[];
  targetCountries: Country[];
}

class CallToolView extends Component {
  state: OwnState;
  props: OwnProps;

  constructor(props: OwnProps) {
    super(props);
    this.state = {
      form: {},
      errors: {},
      loading: false
    };
  }

  countryCodeChanged(countryCode: string) {
    this.setState({
      form: Object.assign({}, this.state.form, {countryCode: countryCode}),
      selectedTarget: this.selectNewTarget(countryCode),
      errors: Object.assign({}, this.state.errors, { countryCode: null })
    });
  }

  memberPhoneNumberChanged(memberPhoneNumber: string) {
    this.setState({
      form: Object.assign({}, this.state.form, {memberPhoneNumber: memberPhoneNumber}),
      errors: Object.assign({}, this.state.errors, { memberPhoneNumber: null })
    });
  }

  selectNewTarget(countryCode: string) {
    const candidates = _.filter(this.props.targets, t => { return t.countryCode === countryCode; });
    return _.sample(candidates);
  }

  selectedTargetIndex() {
    return _.findIndex(this.props.targets, this.state.selectedTarget);
  }

  submit(event: any) {
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

  submitSuccessful(response: OperationResponse) {
    this.setState({errors: {}, loading: false});
  }

  submitFailed(response: OperationResponse) {
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
        { this.props.title &&
          <h1> { this.props.title } </h1>
        }

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

export default CallToolView;

