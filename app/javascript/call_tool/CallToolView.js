// @flow
import React, { Component } from 'react';
import { FormattedMessage, injectIntl } from 'react-intl';
import isEmpty from 'lodash/isEmpty';
import filter from 'lodash/filter';
import find from 'lodash/find';
import sample from 'lodash/sample';
import ChampaignAPI from '../util/ChampaignAPI';
import type { OperationResponse } from '../util/ChampaignAPI';
import type { IntlShape } from 'react-intl';

import Form from '../components/CallTool/Form';

export type Target = {
  countryCode: string,
  name: string,
  title: string,
  id: string,
};

export type Country = {
  code: string,
  name: string,
  phoneCode: string,
};

export type CountryPhoneCode = {
  code: string,
  name: string,
};

export type FormType = {
  memberPhoneNumber: string,
  memberPhoneCountryCode: string,
  countryCode: string,
};

export type Errors = {
  memberPhoneNumber?: any,
  memberPhoneCountryCode?: any,
  countryCode?: any,
  base?: any[],
};

type OwnState = {
  form: FormType,
  errors: Errors,
  loading: boolean,
  selectedTarget?: Target,
  selectedCountryCode?: string,
};

type OwnProps = {
  allowManualTargetSelection: boolean,
  restrictedCountryCode: ?string,
  targetByCountryEnabled: boolean,
  memberPhoneNumber?: string,
  countryCode?: string,
  title?: string,
  pageId: string | number,
  targets: Target[],
  countries: Country[],
  countriesPhoneCodes: CountryPhoneCode[],
  onSuccess?: () => void,
  intl: IntlShape,
};

class CallToolView extends Component {
  state: OwnState;
  props: OwnProps;

  constructor(props: OwnProps) {
    super(props);

    this.state = {
      form: {
        memberPhoneNumber: '',
        memberPhoneCountryCode: '',
        countryCode: this.preselectedCountryCode(),
      },
      errors: {},
      loading: false,
      selectedCountryCode: undefined,
    };
  }

  preselectedCountryCode() {
    let countryCode;

    if (this.props.restrictedCountryCode) {
      countryCode = this.props.restrictedCountryCode;
    } else if (this.props.targetByCountryEnabled) {
      // Assign countryCode only if it's a valid one
      const preselectedTarget = find(this.props.targets, target => {
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
    if (!this.props.targetByCountryEnabled) {
      this.setState({ selectedTarget: this.selectNewTarget() });
    }
  }

  countryCodeChanged(countryCode: string) {
    if (this.props.targetByCountryEnabled) {
      this.setState((prevState, props) => {
        return {
          form: {
            ...prevState.form,
            memberPhoneCountryCode: this.guessMemberPhoneCountryCode(
              countryCode
            ),
            countryCode,
          },
          selectedTarget: this.selectNewTargetFromCountryCode(countryCode),
          errors: { ...prevState.errors, countryCode: null },
          selectedCountryCode: countryCode,
        };
      });
    } else {
      this.setState((prevState, props) => {
        return {
          form: {
            ...prevState.form,
            memberPhoneCountryCode: this.guessMemberPhoneCountryCode(
              countryCode
            ),
            countryCode,
          },
        };
      });
    }
  }

  candidates(countryCode) {
    const code = countryCode || this.state.selectedCountryCode;
    if (this.props.targetByCountryEnabled) {
      const candidates = filter(
        this.props.targets,
        t => t.countryCode === code
      );
      console.log('candidates: ', candidates);
      return candidates;
    }
    return this.props.targets;
  }

  guessMemberPhoneCountryCode(countryCode: string) {
    const country = find(this.props.countries, t => {
      return t.code === countryCode;
    });
    return country ? `+${country.phoneCode}` : '';
  }

  memberPhoneNumberChanged(memberPhoneNumber: string) {
    this.setState(prevState => {
      return {
        form: { ...prevState.form, memberPhoneNumber },
        errors: { ...prevState.errors, memberPhoneNumber: null },
      };
    });
  }

  memberPhoneCountryCodeChanged(memberPhoneCountryCode: string) {
    this.setState(prevState => {
      return {
        form: { ...prevState.form, memberPhoneCountryCode },
        errors: { ...prevState.errors, memberPhoneCountryCode: null },
      };
    });
  }

  selectNewTarget() {
    return sample(this.candidates());
  }

  selectTarget = (id: string) => {
    console.log('selectTarget:', id);
    const target = find(this.props.targets, { id });
    this.setState(prevState => ({
      ...prevState,
      selectedTarget: target,
    }));
  };

  selectNewTargetFromCountryCode(countryCode: string) {
    return sample(this.candidates(countryCode));
  }

  submit(event: any) {
    event.preventDefault();
    if (!this.validateForm()) return;
    this.setState({ errors: {}, loading: true });
    ChampaignAPI.calls
      .create({
        pageId: this.props.pageId,
        memberPhoneNumber: this.state.form.memberPhoneCountryCode +
          this.state.form.memberPhoneNumber,
        // $FlowIgnore
        targetId: this.state.selectedTarget.id,
      })
      .then(this.submitSuccessful.bind(this), this.submitFailed.bind(this));
  }

  validateForm() {
    const newErrors = {};

    if (this.props.targetByCountryEnabled) {
      if (isEmpty(this.state.form.memberPhoneCountryCode)) {
        newErrors.memberPhoneCountryCode = (
          <FormattedMessage id="validation.is_required" />
        );
      }

      if (isEmpty(this.state.form.countryCode)) {
        newErrors.countryCode = (
          <FormattedMessage id="validation.is_required" />
        );
      }
    }

    if (isEmpty(this.state.form.memberPhoneNumber)) {
      newErrors.memberPhoneNumber = (
        <FormattedMessage id="validation.is_required" />
      );
    }

    this.updateErrors(newErrors);

    return isEmpty(newErrors);
  }

  submitSuccessful(response: OperationResponse) {
    this.setState({ errors: {}, loading: false });
    this.props.onSuccess && this.props.onSuccess(this.state.selectedTarget);
  }

  submitFailed(response: OperationResponse) {
    const newErrors = {};

    if (!isEmpty(response.errors.memberPhoneNumber)) {
      newErrors.memberPhoneNumber = response.errors.memberPhoneNumber[0];
    }

    if (!isEmpty(response.errors.base)) {
      newErrors.base = response.errors.base;
    }

    this.updateErrors(newErrors);
    this.setState({ loading: false });
  }

  updateErrors(newErrors: any) {
    this.setState((prevState, props) => {
      return { errors: { ...prevState.errors, ...newErrors } };
    });
  }

  instructionsMessageId() {
    if (this.props.restrictedCountryCode) {
      return 'call_tool.instructions_without_country';
    } else {
      return 'call_tool.instructions';
    }
  }

  render() {
    const { errors } = this.state;
    return (
      <div>
        {this.props.title && <h1> {this.props.title} </h1>}

        <p className="select-home-country">
          {' '}<FormattedMessage id={this.instructionsMessageId()} />{' '}
        </p>

        {errors.base !== undefined &&
          !isEmpty(this.state.errors.base) &&
          <div className="base-errors">
            <ul>
              {this.state.errors.base &&
                this.state.errors.base.map((error, index) => {
                  return <li key={`error-${index}`}> {error} </li>;
                })}
            </ul>
          </div>}

        <Form
          allowManualTargetSelection={this.props.allowManualTargetSelection}
          targetByCountryEnabled={this.props.targetByCountryEnabled}
          restrictToSingleCountry={!!this.props.restrictedCountryCode}
          countries={this.props.countries}
          countriesPhoneCodes={this.props.countriesPhoneCodes}
          targets={this.candidates()}
          selectedTarget={this.state.selectedTarget}
          form={this.state.form}
          errors={this.state.errors}
          onCountryCodeChange={this.countryCodeChanged.bind(this)}
          onMemberPhoneNumberChange={this.memberPhoneNumberChanged.bind(this)}
          onMemberPhoneCountryCodeChange={this.memberPhoneCountryCodeChanged.bind(
            this
          )}
          onTargetSelected={id => this.selectTarget(id)}
          onSubmit={this.submit.bind(this)}
          loading={this.state.loading}
        />
        <p
          className="fine-print"
          dangerouslySetInnerHTML={{
            __html: this.props.intl.formatMessage({
              id: 'call_tool.fine_print',
            }),
          }}
        />
      </div>
    );
  }
}

export default injectIntl(CallToolView);
