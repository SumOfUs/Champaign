import React, { Component } from 'react';
import Select from 'react-select';
import { FormattedMessage } from 'react-intl';
import sortBy from 'lodash/sortBy';
import countryData from 'country-data/data/countries.json';
import Button from '../Button/Button';
import SweetInput from '../SweetInput/SweetInput';
import './MemberDetailsForm.css';
import 'react-select/dist/react-select.css';

type OwnProps = {
  buttonText?: ReactNode | string;
};

export class MemberDetailsForm extends Component {
  props: OwnProps;

  state: {
    countries: any;
    email: ?string;
    fullName: ?string;
    country: ?string;
    postal: ?string;
  }

  static title = <FormattedMessage id="details" defaultMessage="details" />;

  constructor(props: OwnProps) {
    super(props);
    const countries = sortBy(countryData
      .filter(c => c.status === 'assigned')
      .filter(c => c.ioc !== '')
      .map(c => ({ value: c.ioc, label: c.name })), 'label');

    this.state = {
      countries,
      country: null,
      email: null,
      fullName: null,
      postal: null,
    };
  }

  isFormValid() {
    const { email, country } = this.state;
    return email && country;
  }

  submit() {

  }

  render() {
    return (
      <div className="MemberDetailsForm-root">
        <div className="MemberDetailsForm-field">
          <SweetInput
            name="email"
            type="email"
            label={<FormattedMessage id="email" defaultMessage="Email" />}
            onChange={value => this.setState({ email: value })}
          />
        </div>

        <div className="MemberDetailsForm-field">
          <SweetInput
            name="full_name"
            label={<FormattedMessage id="full_name" defaultMessage="Full name" />}
            onChange={value => this.setState({ fullName: value })}
          />
        </div>

        <div className="MemberDetailsForm-field">
          <Select
            style={{marginBottom: '10px'}}
            ref="countrySelect"
            name="country"
            placeholder={<FormattedMessage id="country" defaultMessage="Country" />}
            simpleValue
            clearable
            searchable
            value={this.state.country}
            options={this.state.countries}
            onChange={(e => this.setState({ country: e }))}
          />
        </div>

        <div className="MemberDetailsForm-field">
          <SweetInput
            name="postal"
            label={<FormattedMessage id="postal" defaultMessage="Postal Code" />}
            onChange={value => this.setState({ postal: value })}
          />
        </div>

        <Button disabled={!this.isFormValid()} onClick={this.submit.bind(this)}>
          { this.props.buttonText ?
            this.props.buttonText :
            <FormattedMessage
              id="submit"
              defaultMessage="submit"
            />
          }
        </Button>
      </div>
    );
  }
}
export default MemberDetailsForm;
