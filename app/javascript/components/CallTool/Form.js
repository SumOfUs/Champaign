// @flow
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import { findKey, sample, compact } from 'lodash';
import classnames from 'classnames';

import CallToolDrillDown from './CallToolDrillDown';
import SelectedTarget from './SelectedTarget';
import Button from '../Button/Button';
import { countries } from '../SelectCountry/SelectCountry';
import SweetPhoneInput from '../SweetPhoneInput/SweetPhoneInput';

import { targetsWithFields, filterTargets } from './call_tool_helpers';
import type { Filters, TargetWithFields } from './call_tool_helpers';

import type {
  Country,
  CountryPhoneCode,
  Target,
  FormType,
  Errors,
} from '../../call_tool/CallToolView';

type Props = {
  targets: Target[],
  selectedTarget: Target,
  restrictToSingleCountry: boolean,
  targetByAttributes: string[],
  form: FormType,
  errors: Errors,
  onTargetSelected: (id: ?string) => void,
  onSubmit: any => void,
  loading: boolean,
  filters?: Filters,
};

type State = {
  targetsWithFields: TargetWithFields[],
  memberPhoneNumber: string,
  countryCode: ?string,
};

class Form extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);

    this.state = {
      targetsWithFields: targetsWithFields(props.targets),
      countryCode: null,
      memberPhoneNumber: '',
    };
  }

  componentWillReceiveProps(nextProps: Props) {
    this.setState((prevState: State) => ({
      ...prevState,
      targetsWithFields: targetsWithFields(nextProps.targets),
    }));
  }

  attemptCountryCodeUpdate(countryName: string = '') {
    const countryCode = findKey(
      countries,
      c => c.toLowerCase() === countryName.toLowerCase()
    );

    this.setState(state => ({ ...state, countryCode }));
  }

  selectTarget(target: ?TargetWithFields) {
    if (target && target.id) {
      this.props.onTargetSelected(target.id);
      this.attemptCountryCodeUpdate(target['countryName'] || target['country']);
    } else {
      this.props.onTargetSelected(null);
      this.attemptCountryCodeUpdate('');
    }
  }

  updatePhoneNumber(memberPhoneNumber: string) {
    this.setState(prevState => ({
      ...prevState,
      memberPhoneNumber,
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
        <CallToolDrillDown
          targetByAttributes={compact(this.props.targetByAttributes || [])}
          filters={this.props.filters}
          targets={this.state.targetsWithFields}
          onUpdate={t => this.selectTarget(t)}
        />

        <SelectedTarget target={this.props.selectedTarget} />

        <SweetPhoneInput
          value={this.state.memberPhoneNumber}
          defaultCountry={this.state.countryCode}
          onChange={(number: string) => this.updatePhoneNumber(number)}
        />

        <Button
          type="submit"
          onClick={this.props.onSubmit}
          disabled={this.props.loading}
        >
          <FormattedMessage id="call_tool.form.submit" />
        </Button>
      </form>
    );
  }
}

export default Form;
