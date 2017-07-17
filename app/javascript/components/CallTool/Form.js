// @flow weak
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import classnames from 'classnames';

import CallToolDrillDown from './CallToolDrillDown';
import ManualTargetSelection from './ManualTargetSelection';
import SelectedTarget from './SelectedTarget';
import Button from '../Button/Button';
import SweetPhoneInput from '../SweetPhoneInput/SweetPhoneInput';

import { targetsWithFields } from './call_tool_helpers';
import type { TargetWithFields } from './call_tool_helpers';

import type {
  Country,
  CountryPhoneCode,
  Target,
  FormType,
  Errors,
} from '../../call_tool/CallToolView';

type OwnProps = {
  targets: Target[],
  selectedTarget: Target,
  allowManualTargetSelection: boolean,
  restrictToSingleCountry: boolean,
  targetByAttributes: string[],
  form: FormType,
  errors: Errors,
  onTargetSelected: (id: string) => void,
  onSubmit: any => void,
  loading: boolean,
};

type OwnState = {
  targetsWithFields: { [string]: string }[],
  filters: { [string]: string },
  countryCode: ?string,
  memberPhoneNumber: ?string,
  memberPhoneCountryCode: ?string,
};

class Form extends Component<*, OwnProps, OwnState> {
  constructor(props: OwnProps) {
    super(props);

    this.state = {
      targetsWithFields: targetsWithFields(props.targets),
      filters: {},
      countryCode: null,
      memberPhoneNumber: null,
      memberPhoneCountryCode: null,
    };
  }

  componentWillReceiveProps(nextProps: OwnProps) {
    this.setState(prevState => ({
      ...prevState,
      targetsWithFields: targetsWithFields(nextProps.targets),
    }));
  }

  render() {
    const formClassNames = classnames({
      'action-form': true,
      'form--big': true,
      'single-country': this.props.restrictToSingleCountry,
    });
    return (
      <form className={formClassNames}>
        <SweetPhoneInput
          value={this.state.memberPhoneNumber}
          onChange={(memberPhoneNumber: string) =>
            this.setState({ memberPhoneNumber })}
        />

        <ManualTargetSelection
          enabled={this.props.allowManualTargetSelection}
          targets={this.state.filteredTargets}
          target={this.props.selectedTarget}
          onChange={(target: Target) => console.log('Selected target:', target)}
        />

        <SelectedTarget target={this.props.selectedTarget} />

        <Button
          type="submit"
          onClick={this.props.onSubmit}
          disabled={this.props.loading ? 'disabled' : ''}
        >
          <FormattedMessage id="call_tool.form.submit" />
        </Button>
      </form>
    );
  }
}

export default Form;
