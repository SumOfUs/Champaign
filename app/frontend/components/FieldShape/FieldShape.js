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
    errorMessage?: string;
    onChange?: (v: SyntheticEvent | string) => void;
  };

  fieldProps() {
    const { field } = this.props;
    return {
      name: field.name,
      label: field.label,
      disabled: field.disabled,
      required: field.required,
      value: field.default_value,
      errorMessage: this.props.errorMessage,
      onChange: this.props.onChange,
    };
  }

  fieldType() {
    return this.props.field.data_type;
  }

  render() {
    const { field: { data_type, default_value, name } } = this.props;
    const fieldProps = this.fieldProps();

    switch (data_type) {
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
}
