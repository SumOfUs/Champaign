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
  id: string;
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
  countryCode: string;
}

export type Errors = {
  memberPhoneNumber?: any;
  memberPhoneCountryCode?: any;
  countryCode?: any;
  base?: any[];
}

type OwnState = {
  form: FormType;
  errors: Errors;
  loading: boolean;
  selectedTarget?: Target;
}

type OwnProps = {
  targetByCountryEnabled: boolean;
  memberPhoneNumber?: string;
  countryCode?: string;
  title?: string;
  pageId: string | number;
  targets: Target[];
  countries: Country[];
  countriesPhoneCodes: CountryPhoneCode[];
  onSuccess?: () => void;
  intl: IntlShape;
}

class CallToolView extends Component {
  state: OwnState;
  props: OwnProps;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      form: {
        memberPhoneNumber: '',
        memberPhoneCountryCode: '',
        countryCode: this.preselectedCountryCode()
      },
      errors: {},
      loading: false
    };
  }

  preselectedCountryCode() {
    let countryCode;

    if(this.props.targetByCountryEnabled) {
      // Assign countryCode only if it's a valid one
      const preselectedTarget = _.find(this.props.targets, target => {
        return target.countryCode === this.props.countryCode;
      });
      countryCode = preselectedTarget ? preselectedTarget.countryCode : '';
    } else {
      countryCode = this.props.countryCode || '';
    }

    return countryCode;
  }

  componentDidMount() {
    this.countryCodeChanged(this.state.form.countryCode);
    if(!this.props.targetByCountryEnabled) {
      this.setState({selectedTarget: this.selectNewTarget() });
    }
  }

  countryCodeChanged(countryCode: string) {
    if(this.props.targetByCountryEnabled) {
      this.setState((prevState, props) => {
        return {
          form: { ...prevState.form, memberPhoneCountryCode: this.guessMemberPhoneCountryCode(countryCode), countryCode },
          selectedTarget: this.selectNewTargetFromCountryCode(countryCode),
          errors: {...prevState.errors, countryCode: null }
        };
      });
    } else {
      this.setState((prevState, props) => {
        return { form: { ...prevState.form, memberPhoneCountryCode: this.guessMemberPhoneCountryCode(countryCode), countryCode }};
      });
    }
  }

  guessMemberPhoneCountryCode(countryCode: string) {
    const country = _.find(this.props.countries, t => { return t.code === countryCode; });
    return country ? `+${country.phoneCode}` : '';
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

  selectNewTarget() {
    return _.sample(this.props.targets);
  }

  selectNewTargetFromCountryCode(countryCode: string) {
    const candidates = _.filter(this.props.targets, t => { return t.countryCode === countryCode; });
    return _.sample(candidates);
  }

  submit(event: any) {
    event.preventDefault();
    if(!this.validateForm()) return;
    this.setState({ errors: {}, loading: true });
    ChampaignAPI.calls.create({
      pageId: this.props.pageId,
      memberPhoneNumber: this.state.form.memberPhoneCountryCode + this.state.form.memberPhoneNumber,
      targetId: (this.state.selectedTarget && this.state.selectedTarget.id) || '' //The || is just to comply with flow
    }).then(this.submitSuccessful.bind(this), this.submitFailed.bind(this));
  }

  validateForm() {
    const newErrors = {};

    if(this.props.targetByCountryEnabled) {
      if(_.isEmpty(this.state.form.memberPhoneCountryCode)) {
        newErrors.memberPhoneCountryCode = <FormattedMessage id="validation.is_required" />;
      }

      if(_.isEmpty(this.state.form.countryCode)) {
        newErrors.countryCode = <FormattedMessage id="validation.is_required" />;
      }
    }

    if(_.isEmpty(this.state.form.memberPhoneNumber)) {
      newErrors.memberPhoneNumber = <FormattedMessage id="validation.is_required" />;
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
          targetByCountryEnabled={this.props.targetByCountryEnabled}
          countries={this.props.countries}
          countriesPhoneCodes={this.props.countriesPhoneCodes}
          targets={this.props.targets}
          selectedTarget={this.state.selectedTarget}
          form={this.state.form}
          errors={this.state.errors}
          onCountryCodeChange={this.countryCodeChanged.bind(this)}
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

