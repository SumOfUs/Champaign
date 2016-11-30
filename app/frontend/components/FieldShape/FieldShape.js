// @flow
import React, { Component } from 'react';
import SweetInput from '../SweetInput/SweetInput';
import SelectCountry from '../SelectCountry';
import Select from 'react-select';

type Field = {
  data_type: string;
  name: string;
  label: string;
  default_value?: string;
  required?: boolean;
  disabled?: boolean;
};

export default class FieldShape extends Component {
  props: {
    field: Field;
    value?: any;
    errorMessage?: string;
    onChange?: (v: SyntheticEvent | string) => void;
  };

  fieldProps() {
    const { field, value } = this.props;
    return {
      name: field.name,
      label: field.label,
      disabled: field.disabled,
      required: field.required,
      value: value || field.default_value,
      errorMessage: this.props.errorMessage,
      onChange: this.props.onChange,
    };
  }

  fieldType() {
    return this.props.field.data_type;
  }

  renderField(type: string): React$Element<any> {
    const fieldProps = this.fieldProps();
    const { field: { data_type, default_value, name } } = this.props;

    switch (type) {
      case 'email':
        return <SweetInput type="email" {...fieldProps} />;
      case 'phone':
      case 'numeric':
        return <SweetInput type="tel" {...fieldProps} />;
      case 'country':
        return <SelectCountry {...fieldProps} />;
      case 'dropdown':
        return <Select {...fieldProps} />;
      case 'hidden':
        return <input type="hidden" name={name} value={default_value} />;
      case 'checkbox':
      case 'choice':
        return <p>{data_type} pending implementation</p>;
      case 'text':
      case 'postal':
      default:
        return <SweetInput type="text" {...fieldProps} />;
    }
  }

  render() {
    return (
      <div key={this.props.field.name} className="MemberDetailsForm-field form__group action-form__field-container">
        {this.renderField(this.props.field.data_type)}
      </div>
    );
  }
}
