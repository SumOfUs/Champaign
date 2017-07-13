// @flow weak
import React, { Component } from 'react';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import classnames from 'classnames';
import CallToolDrillDown from './CallToolDrillDown';
import FieldShape from '../../components/FieldShape/FieldShape';
import type { Choice } from '../../components/FieldShape/FieldShape';
import type {
  Country,
  CountryPhoneCode,
  Target,
  FormType,
  Errors,
} from '../../call_tool/CallToolView';
import type { Field } from '../../components/FieldShape/FieldShape';

type OwnProps = {
  allowManualTargetSelection: boolean,
  restrictToSingleCountry: boolean,
  countries: Country[],
  targets: Target[],
  countriesPhoneCodes: CountryPhoneCode[],
  selectedTarget: Target,
  form: FormType,
  errors: Errors,
  onCountryCodeChange: string => void,
  onMemberPhoneNumberChange: string => void,
  onMemberPhoneCountryCodeChange: string => void,
  onTargetSelected: (id: string) => void,
  onSubmit: any => void,
  targetByAttributes: string[],
  loading: boolean,
};

const memberPhoneNumberField: Field = {
  data_type: 'phone',
  name: 'call_tool[member_phone_number]',
  label: <FormattedMessage id="call_tool.form.phone_number" />,
  default_value: '',
  required: true,
  disabled: false,
};

const memberPhoneCountryCodeField: Field = {
  data_type: 'phone',
  name: 'call_tool[member_phone_number]',
  label: <FormattedMessage id="call_tool.form.phone_country_code" />,
  default_value: '',
  required: true,
  disabled: false,
};

const countryCodeField: Field = {
  data_type: 'select',
  name: 'call_tool[country_code]',
  label: <FormattedMessage id="call_tool.form.country" />,
  default_value: null,
  required: true,
  disabled: false,
  choices: [],
};

const targetField: Field = {
  data_type: 'select',
  name: 'call_tool[target]',
  label: <FormattedMessage id="call_tool.manual_target_selection" />,
  default_value: null,
  required: true,
  disabled: false,
  choices: [],
};

class Form extends Component {
  props: OwnProps;
  state: {
    filters: { [string]: string },
  };

  fields: { [key: string]: Field };

  constructor(props: OwnProps) {
    super(props);

    // FIXME: Use this.state for all these
    // that way this.setState(...) updates these and triggers a re-render
    this.fields = {
      memberPhoneNumberField: memberPhoneNumberField,
      memberPhoneCountryCodeField: memberPhoneCountryCodeField,
      countryCodeField: {
        ...countryCodeField,
        choices: this.countryCodeOptions(),
      },
    };

    this.state = {
      filters: {},
    };
  }

  countryCodeOptions() {
    return this.props.countries.map(country => {
      return { id: country.code, value: country.code, label: country.name };
    });
  }

  targetFields() {
    return {
      ...targetField,
      choices: this.targetOptions(),
    };
  }

  targetOptions(): Choice[] {
    return this.filteredTargets(this.state.filters).map((target: Target) => ({
      id: `target-${target.id}`,
      value: target.id,
      label: (
        <div>
          <p style={{ fontSize: '90%' }}>
            {target.postalCode && <span>({target.postalCode})</span>}
            {' - '}
            <strong>{target.name}</strong>
            {' '}
            <span style={{ fontSize: '70%' }}>{target.title}</span>
          </p>
        </div>
      ),
    }));
  }

  phoneNumberCountryName() {
    const strippedCountryCode = this.props.form.memberPhoneCountryCode.replace(
      '+',
      ''
    );
    const countryPhoneCode = _.find(
      this.props.countriesPhoneCodes,
      countryCode => {
        return countryCode.code === strippedCountryCode;
      }
    );

    return countryPhoneCode ? countryPhoneCode.name : '';
  }

  updateFilters = (filters: { [string]: string }) => {
    this.setState(
      prevState => ({ ...prevState, filters }),
      () => {
        // TODO:
        // reset selected target if selectedTarget is not in this.filteredTargets
      }
    );
  };

  targetsWithFields() {
    return this.props.targets.map(t => ({
      ..._.omit(t, 'fields'),
      ..._.get(t, 'fields', {}),
    }));
  }

  filteredTargets(filters: { [string]: string }): Target[] {
    const targets = this.targetsWithFields();
    if (!Object.keys(filters).length) return targets;
    return targets.filter((target: Target) => {
      return _.isMatch(target, filters);
    });
  }

  render() {
    const formClassNames = classnames({
      'action-form': true,
      'form--big': true,
      'single-country': this.props.restrictToSingleCountry,
    });
    return (
      <form className={formClassNames} data-remote="true">
        {!this.props.restrictToSingleCountry &&
          <FieldShape
            key="memberPhoneCountryCode"
            errorMessage={this.props.errors.memberPhoneCountryCode}
            onChange={this.props.onMemberPhoneCountryCodeChange}
            value={this.props.form.memberPhoneCountryCode}
            field={this.fields.memberPhoneCountryCodeField}
            className="phoneCountryCodeField"
          />}

        <FieldShape
          key="memberPhoneNumber"
          errorMessage={this.props.errors.memberPhoneNumber}
          onChange={this.props.onMemberPhoneNumberChange}
          value={this.props.form.memberPhoneNumber}
          field={this.fields.memberPhoneNumberField}
          className="phoneNumberField"
        />

        {!this.props.restrictToSingleCountry &&
          <p
            className={classnames({
              'guessed-country-name': true,
              hidden: !_.isEmpty(this.props.errors.memberPhoneNumber),
            })}
          >
            <span>
              {this.phoneNumberCountryName()}
            </span>
          </p>}

        <div className="clearfix"> </div>

        {this.props.allowManualTargetSelection &&
          <CallToolDrillDown
            targetByAttributes={_.compact(this.props.targetByAttributes)}
            filters={this.state.filters}
            targets={this.targetsWithFields()}
            onUpdate={this.updateFilters}
          />}
        {this.props.allowManualTargetSelection &&
          this.props.selectedTarget &&
          <FieldShape
            key="selectedTarget"
            onChange={this.props.onTargetSelected}
            value={this.props.selectedTarget.id}
            field={this.targetFields()}
          />}

        {!_.isEmpty(this.props.selectedTarget) &&
          <SelectedTarget {...this.props.selectedTarget} />}

        <button
          type="submit"
          onClick={this.props.onSubmit}
          className="button action-form__submit-button"
          disabled={this.props.loading ? 'disabled' : ''}
        >
          <FormattedMessage id="call_tool.form.submit" />
        </button>
      </form>
    );
  }
}

function SelectedTarget(props: { name: string, title?: string }) {
  return (
    <div className="selectedTarget">
      <p>
        <span>
          <FormattedMessage id="call_tool.you_will_be_calling" />
          &nbsp;
          <span className="selectedTargetName">
            {props.name}
          </span>
          {props.title && <span>, {props.title} </span>}
        </span>
      </p>
    </div>
  );
}

export default Form;
