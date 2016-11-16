import React, { Component } from 'react';
import Select from 'react-select';
import { injectIntl, FormattedMessage } from 'react-intl';
import SweetInput from '../SweetInput/SweetInput';
import countries from 'country-data/data/countries.json';
import './MemberDetailsForm.css';
import 'react-select/dist/react-select.css';

type OwnProps = {
  nextStepTitle: string;
  intl: any;
};

export class MemberDetailsForm extends Component {
  props: OwnProps;

  static title = <FormattedMessage id="details" defaultMessage="details" />;

  constructor(props: OwnProps) {
    super(props);
    this.state = {
      countries: countries.filter(c => c.status === 'assigned' && c.ioc !== ''),
      country: null,
    };
  }
  render() {
    const { intl } = this.props;
    return (
      <div className="MemberDetailsForm-root">
        <div className="MemberDetailsForm-field">
          <SweetInput name="email" label={<FormattedMessage id="email" defaultMessage="Email" />} />
        </div>

        <div className="MemberDetailsForm-field">
          <input
            type="text"
            className="input-field"
            name="full_name"
            placeholder={this.props.intl.formatMessage({
              id: 'full_name',
              defaultMessage: 'Full name'
            })}
          />
        </div>

        <div className="MemberDetailsForm-field">
          <Select
            ref="countrySelect"
            name="country"
            simpleValue
            clearable
            searchable
            value={this.state.country}
            options={countries.map(c => ({ value: c.ioc, label: c.name })).filter(c => c.value)}
            onChange={(e => this.setState({ country: e }))}
          />
        </div>

        <div className="MemberDetailsForm-field">
          <input
            type="text"
            className="input-field"
            name="postal_code"
            placeholder={this.props.intl.formatMessage({
              id: 'postal_code',
              defaultMessage: 'Postal Code'
            })}
          />
        </div>

        <button>
          <FormattedMessage
            id="proceed_to_x"
            defaultMessage="Proceed to {x}"
            values={{x: this.props.nextStepTitle}}
          />
        </button>
      </div>
    );
  }
}
export default injectIntl(MemberDetailsForm);
