// @flow weak
import React, { Component } from 'react';
import { FormattedMessage, injectIntl } from 'react-intl';
import { camelCase, isEmpty, filter, find, sample } from 'lodash';
import ChampaignAPI from '../util/ChampaignAPI';
import Form from '../components/CallTool/Form';

import type { OperationResponse } from '../util/ChampaignAPI';
import type { IntlShape } from 'react-intl';

export type Target = {
  id: string,
  title: string,
  name: string,
  countryCode?: string,
  countryName?: string,
  fields?: { [string]: string },
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
  targetByAttributes: string[],
  memberPhoneNumber?: string,
  countryCode?: string,
  title?: string,
  pageId: string | number,
  targets: Target[],
  countries: Country[],
  countriesPhoneCodes: CountryPhoneCode[],
  onSuccess?: (target: any) => void,
  targetPhoneNumber?: string,
  targetPhoneExtension?: string,
  targetName?: string,
  targetTitle?: string,
  checksum?: string,
  intl: IntlShape,
  trackingParams: any,
  filters?: any,
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
    let countryCode: string;

    if (this.props.restrictedCountryCode) {
      countryCode = this.props.restrictedCountryCode;
    } else {
      countryCode = this.props.countryCode || '';
    }
    return countryCode;
  }

  componentDidMount() {
    this.countryCodeChanged(this.state.form.countryCode);
  }

  countryCodeChanged(countryCode: string) {
    this.setState((prevState, props) => {
      return {
        form: {
          ...prevState.form,
          memberPhoneCountryCode: this.guessMemberPhoneCountryCode(countryCode),
          countryCode,
        },
      };
    });
  }

  hasPrefilledTarget() {
    return !!this.props.targetPhoneNumber && !!this.props.checksum;
  }

  prefilledTargetForDisplay() {
    return {
      countryCode: '',
      name: this.props.targetName,
      title: this.props.targetTitle,
      id: 'prefilled',
    };
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
    return sample(this.props.targets);
  }

  selectTarget(id: ?string) {
    const target = find(this.props.targets, { id });
    this.setState(prevState => ({
      ...prevState,
      selectedTarget: target,
    }));
  }

  submit(event: any) {
    event.preventDefault();
    if (!this.validateForm()) return;
    this.setState({ errors: {}, loading: true });
    ChampaignAPI.calls
      .create({
        ...this.targetHash(),
        pageId: this.props.pageId,
        memberPhoneNumber:
          this.state.form.memberPhoneCountryCode +
          this.state.form.memberPhoneNumber,
        trackingParams: this.props.trackingParams,
      })
      .then(this.submitSuccessful.bind(this), this.submitFailed.bind(this));
  }

  targetHash() {
    if (this.hasPrefilledTarget()) {
      return {
        targetPhoneExtension: this.props.targetPhoneExtension,
        targetPhoneNumber: this.props.targetPhoneNumber,
        targetTitle: this.props.targetTitle,
        targetName: this.props.targetName,
        checksum: this.props.checksum,
      };
    } else {
      return {
        // $FlowIgnore
        targetId: this.state.selectedTarget.id,
      };
    }
  }

  validateForm() {
    const newErrors = {};

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
        {this.props.title &&
          <h1>
            {' '}{this.props.title}{' '}
          </h1>}

        <p className="select-home-country">
          {' '}<FormattedMessage id={this.instructionsMessageId()} />{' '}
        </p>

        {errors.base !== undefined &&
          !isEmpty(this.state.errors.base) &&
          <div className="base-errors">
            <ul>
              {this.state.errors.base &&
                this.state.errors.base.map((error, index) => {
                  return (
                    <li key={`error-${index}`}>
                      {' '}{error}{' '}
                    </li>
                  );
                })}
            </ul>
          </div>}

        <Form
          allowManualTargetSelection={
            this.props.allowManualTargetSelection && !this.hasPrefilledTarget()
          }
          restrictToSingleCountry={!!this.props.restrictedCountryCode}
          countries={this.props.countries}
          countriesPhoneCodes={this.props.countriesPhoneCodes}
          targets={this.props.targets}
          selectedTarget={
            this.hasPrefilledTarget()
              ? this.prefilledTargetForDisplay()
              : this.state.selectedTarget
          }
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
          targetByAttributes={this.props.targetByAttributes.map(camelCase)}
          filters={this.props.filters}
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
