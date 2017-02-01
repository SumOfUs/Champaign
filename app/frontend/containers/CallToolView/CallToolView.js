// @flow
import React, { Component } from 'react';
import { FormattedMessage, injectIntl } from 'react-intl';
import _ from 'lodash';
import ChampaignAPI from '../../util/ChampaignAPI';
import type { OperationResponse } from '../../util/ChampaignAPI';
import type { IntlShape } from 'react-intl';

import Form from '../../components/CallTool/Form';

export type Target = {
  countryCode: string;
  name: string;
  title: string;
}

export type Country = {
  code: string;
  name: string;
  phoneCode: string;
}

export type CountryPhoneCode = {
  code: string;
  name: string;
}

export type FormType = {
  memberPhoneNumber: string;
  memberPhoneCountryCode: string;
  targetCountryCode: string;
}

export type Errors = {
  memberPhoneNumber?: any;
  memberPhoneCountryCode?: any;
  targetCountryCode?: any;
  base?: any[];
}

type OwnState = {
  form: FormType;
  errors: Errors;
  loading: boolean;
  selectedTarget?: Target;
}

type OwnProps = {
  memberPhoneNumber?: string;
  targetCountryCode?: string;
  title?: string;
  pageId: string | number;
  targets: Target[];
  targetCountries: Country[];
  countriesPhoneCodes: CountryPhoneCode[];
  onSuccess?: () => void;
  intl: IntlShape;
}

class CallToolView extends Component {
  state: OwnState;
  props: OwnProps;

  constructor(props: OwnProps) {
    super(props);
    // Assign targetCountryCode only if it's a valid one
    const preselectedTarget = _.find(this.props.targets, target => {
      return target.countryCode === this.props.targetCountryCode;
    });

    this.state = {
      form: {
        memberPhoneNumber: '',
        memberPhoneCountryCode: '',
        targetCountryCode: preselectedTarget ? preselectedTarget.countryCode : '',
      },
      errors: {},
      loading: false
    };
  }

  componentDidMount() {
    this.targetCountryCodeChanged(this.state.form.targetCountryCode);
  }

  targetCountryCodeChanged(targetCountryCode: string) {
    this.setState((prevState, props) => {
      return {
        form: { ...prevState.form, memberPhoneCountryCode: this.guessMemberPhoneCountryCode(targetCountryCode), targetCountryCode },
        selectedTarget: this.selectNewTarget(targetCountryCode),
        errors: {...prevState.errors, targetCountryCode: null }
      };
    });
  }

  guessMemberPhoneCountryCode(countryCode: string) {
    const target = _.find(this.props.targetCountries, t => { return t.code === countryCode; });
    return target ? `+${target.phoneCode}` : '';
  }

  memberPhoneNumberChanged(memberPhoneNumber: string) {
    this.setState((prevState) => {
      return {
        form: {...prevState.form, memberPhoneNumber },
        errors: {...prevState.errors, memberPhoneNumber: null }
      };
    });
  }

  memberPhoneCountryCodeChanged(memberPhoneCountryCode: string) {
    this.setState((prevState) => {
      return {
        form: {...prevState.form, memberPhoneCountryCode },
        errors: {...prevState.errors, memberPhoneCountryCode: null }
      };
    });
  }

  selectNewTarget(targetCountryCode: string) {
    const candidates = _.filter(this.props.targets, t => { return t.countryCode === targetCountryCode; });
    return _.sample(candidates);
  }

  selectedTargetIndex() {
    return _.findIndex(this.props.targets, this.state.selectedTarget);
  }

  submit(event: any) {
    event.preventDefault();
    if(!this.validateForm()) return;
    this.setState({ errors: {}, loading: true });
    ChampaignAPI.calls.create({
      pageId: this.props.pageId,
      memberPhoneNumber: this.state.form.memberPhoneCountryCode + this.state.form.memberPhoneNumber,
      targetIndex: this.selectedTargetIndex()
    }).then(this.submitSuccessful.bind(this), this.submitFailed.bind(this));
  }

  validateForm() {
    const newErrors = {};

    if(_.isEmpty(this.state.form.memberPhoneCountryCode)) {
      newErrors.memberPhoneCountryCode = <FormattedMessage id="validation.is_required" />;
    }

    if(_.isEmpty(this.state.form.memberPhoneNumber)) {
      newErrors.memberPhoneNumber = <FormattedMessage id="validation.is_required" />;
    }

    if(_.isEmpty(this.state.form.targetCountryCode)) {
      newErrors.targetCountryCode = <FormattedMessage id="validation.is_required" />;
    }

    this.updateErrors(newErrors);

    return _.isEmpty(newErrors);
  }

  submitSuccessful(response: OperationResponse) {
    this.setState({errors: {}, loading: false});
    this.props.onSuccess && this.props.onSuccess(this.state.selectedTarget);
  }

  submitFailed(response: OperationResponse) {
    const newErrors = {};

    if(!_.isEmpty(response.errors.memberPhoneNumber)) {
      newErrors.memberPhoneNumber = response.errors.memberPhoneNumber[0];
    }

    if(!_.isEmpty(response.errors.base)) {
      newErrors.base = response.errors.base;
    }

    this.updateErrors(newErrors);
    this.setState({loading: false});
  }

  updateErrors(newErrors: any) {
    this.setState((prevState, props) => {
      return { errors: {...prevState.errors, ...newErrors } };
    });
  }

  render() {
    const {errors} = this.state;
    return (
      <div>
        { this.props.title &&
          <h1> { this.props.title } </h1>
        }

        <p className='select-home-country'> <FormattedMessage id="call_tool.select_target" /> </p>

        { errors.base !== undefined && !_.isEmpty(this.state.errors.base) &&
          <div className="base-errors">
            <ul>
              { this.state.errors.base && this.state.errors.base.map((error, index) => {
                  return <li key={`error-${index}`}> {error} </li>;
                })
              }
            </ul>
          </div>
        }

        <Form
          targetCountries={this.props.targetCountries}
          countriesPhoneCodes={this.props.countriesPhoneCodes}
          targets={this.props.targets}
          selectedTarget={this.state.selectedTarget}
          form={this.state.form}
          errors={this.state.errors}
          onTargetCountryCodeChange={this.targetCountryCodeChanged.bind(this)}
          onMemberPhoneNumberChange={this.memberPhoneNumberChanged.bind(this)}
          onMemberPhoneCountryCodeChange={this.memberPhoneCountryCodeChanged.bind(this)}
          onSubmit={this.submit.bind(this)}
          loading={this.state.loading}
        />
        <p className="fine-print" dangerouslySetInnerHTML={{ __html: this.props.intl.formatMessage({ id: 'call_tool.fine_print' })}} />
      </div>
    );
  }
}

export default injectIntl(CallToolView);

