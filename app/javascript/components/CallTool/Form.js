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

class Form extends Component {
  constructor(props) {
    super(props);

    this.state = {
      targetsWithFields: targetsWithFields(props.targets),
      countryCode: undefined,
      memberPhoneNumber: '',
    };
  }

  componentWillReceiveProps(nextProps) {
    this.setState(prevState => ({
      ...prevState,
      targetsWithFields: targetsWithFields(nextProps.targets),
    }));
  }

  attemptCountryCodeUpdate(countryName = '') {
    const countryCode = findKey(
      countries,
      c => c.toLowerCase() === countryName.toLowerCase()
    );

    this.setState(state => ({ ...state, countryCode }));
  }

  selectTarget(target) {
    if (target && target.id) {
      this.props.onTargetSelected(target.id);
      this.attemptCountryCodeUpdate(target['countryName'] || target['country']);
    } else {
      this.props.onTargetSelected(null);
      this.attemptCountryCodeUpdate('');
    }
  }

  updatePhoneNumber(memberPhoneNumber) {
    this.props.onMemberPhoneNumberChange(memberPhoneNumber);
    this.setState(prevState => ({
      ...prevState,
      memberPhoneNumber,
    }));
  }

  render() {
    const formClassNames = classnames({
      'action-form': true,
      'form--big': true,
      'single-country': !!this.props.restrictedCountryCode,
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
          defaultCountryCode={
            this.props.restrictedCountryCode || this.state.countryCode
          }
          onChange={number => this.updatePhoneNumber(number)}
          restrictedCountryCode={this.props.restrictedCountryCode}
          errors={this.props.errors}
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
