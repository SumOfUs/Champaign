// @flow
import React, { Component } from 'react';
import { FormattedMessage, injectIntl } from 'react-intl';
import { camelCase, isEmpty, filter, find, sample } from 'lodash';
import { CallsClient } from '../util/ChampaignClient';
import Form from '../components/CallTool/Form';

import type { OperationResponse } from '../util/ChampaignClient';
import type { IntlShape } from 'react-intl';

export type Target = {
  id: string,
  title: string,
  name: string,
  countryCode?: string,
  countryName?: string,
  fields?: { [string]: string },
};

export type Errors = {
  memberPhoneNumber?: any,
  base?: any[],
};

type OwnState = {
  memberPhoneNumber: string,
  errors: Errors,
  loading: boolean,
  selectedTarget: ?Target,
};

type OwnProps = {
  allowManualTargetSelection: boolean,
  restrictedCountryCode?: string,
  targetByAttributes: string[],
  memberPhoneNumber?: string,
  countryCode?: string,
  title?: string,
  pageId: string | number,
  targets: Target[],
  onSuccess?: (target: any) => void,
  targetTitle?: string,
  targetName?: string,
  targetPhoneNumber?: string,
  targetPhoneExtension?: string,
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
      selectedTarget: undefined,
      memberPhoneNumber: props.memberPhoneNumber || '',
      errors: {},
      loading: false,
    };
  }

  hasPrefilledTarget(): boolean {
    return !!this.props.targetPhoneNumber && !!this.props.checksum;
  }

  prefilledTargetForDisplay(): ?Target {
    return {
      name: this.props.targetName || '',
      title: this.props.targetTitle || '',
      id: 'prefilled',
    };
  }

  memberPhoneNumberChanged(memberPhoneNumber: string) {
    this.setState(prevState => {
      return {
        ...prevState,
        memberPhoneNumber,
        errors: { ...prevState.errors, memberPhoneNumber: null },
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
    CallsClient.create({
      ...this.targetObject(),
      pageId: this.props.pageId,
      memberPhoneNumber: this.state.memberPhoneNumber,
      trackingParams: this.props.trackingParams,
    }).then(this.submitSuccessful.bind(this), this.submitFailed.bind(this));
  }

  targetObject(): any {
    if (this.hasPrefilledTarget()) {
      return {
        targetTitle: this.props.targetTitle,
        targetName: this.props.targetName,
        targetPhoneExtension: this.props.targetPhoneExtension,
        targetPhoneNumber: this.props.targetPhoneNumber,
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

    if (isEmpty(this.state.memberPhoneNumber)) {
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

  render() {
    const { errors } = this.state;
    return (
      <div>
        {this.props.title && <h1> {this.props.title} </h1>}

        <p className="instructions">
          <FormattedMessage id="call_tool.instructions" />
        </p>

        {errors.base !== undefined &&
          !isEmpty(this.state.errors.base) && (
            <div className="base-errors">
              <ul>
                {this.state.errors.base &&
                  this.state.errors.base.map((error, index) => {
                    return <li key={`error-${index}`}> {error} </li>;
                  })}
              </ul>
            </div>
          )}

        <Form
          restrictedCountryCode={this.props.restrictedCountryCode}
          targets={this.props.targets}
          selectedTarget={
            this.hasPrefilledTarget()
              ? this.prefilledTargetForDisplay()
              : this.state.selectedTarget
          }
          errors={this.state.errors}
          onMemberPhoneNumberChange={this.memberPhoneNumberChanged.bind(this)}
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
