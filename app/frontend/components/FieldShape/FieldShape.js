// @flow
import React, { Component } from 'react';
import SweetInput from '../SweetInput/SweetInput';
import SelectCountry from '../SelectCountry';
import SweetSelect from '../SweetSelect/SweetSelect';
import Checkbox from '../Checkbox/Checkbox';
import type { Element } from 'react';

export type Field = {
  data_type: string;
  name: string;
  label: string;
  default_value: string | null;
  required?: boolean;
  disabled?: boolean;
  choices?: any;
};

type FieldProps = {
  name: string;
  label: string;
  disabled?: boolean;
  required?: boolean;
  value?: any;
  errorMessage?: string | Element<*>;
  onChange?: (v: string) => void;
};

export default class FieldShape extends Component {
  props: {
    field: Field;
    value?: any;
    errorMessage?: string | Element<*>;
    onChange?: (v: string) => void;
    className?: string;
  };

  checkboxToggle(event: SyntheticInputEvent) {
    const checked = event.target.checked;
    this.props.onChange && this.props.onChange(checked ? '1' : '0');
  }

  fieldProps(): FieldProps {
    const { field, value } = this.props;
    return {
      name: field.name,
      label: field.label,
      disabled: field.disabled,
      required: field.required,
      value: value,
      errorMessage: this.props.errorMessage,
      onChange: this.props.onChange,
    };
  }

  errorMessage(fieldProps: FieldProps) {
    if (fieldProps.errorMessage !== null && fieldProps.errorMessage !== undefined) {
      return <span className='error-msg'>{ fieldProps.errorMessage }</span>;
    }
  }

  renderParagraph(fieldProps: FieldProps) {
    return (<div>
      <textarea
        name={ fieldProps.name }
        value={ fieldProps.value }
        placeholder={fieldProps.label}
        onChange={e => fieldProps.onChange && fieldProps.onChange(e.target.value)}
        className={fieldProps.errorMessage ? 'has-error' : ''}
        maxLength="9999">
      </textarea>
      { this.errorMessage(fieldProps) }
    </div>);
  }

  renderCheckbox(fieldProps: FieldProps) {
    fieldProps.value = (fieldProps.value || '0').toString();
    const checked = fieldProps.value === '1' || fieldProps.value === 'checked' || fieldProps.value === 'true';
    return (
      <div>
        <Checkbox checked={checked} onChange={this.checkboxToggle.bind(this)}>
          {fieldProps.label}
        </Checkbox>
        { this.errorMessage(fieldProps)}
      </div>
    );
  }

  renderChoice(fieldProps: FieldProps) {
    const { field } = this.props;
    return (<div className="radio-container">
              <div className="form__instruction">{ fieldProps.label }</div>
              {field.choices && field.choices.map( choice =>
                <label key={choice.id} htmlFor={choice.id}>
                  <input id={choice.id} name={fieldProps.name}
                    type='radio' value={choice.value} checked={choice.value === fieldProps.value}
                    onChange={(event: SyntheticInputEvent) => this.props.onChange && this.props.onChange(event.target.value)} />
                  { choice.label }
                </label>
              )}
              { this.errorMessage(fieldProps)}
            </div>);
  }

  renderField(type: string): Element<any> {
    const fieldProps = this.fieldProps();
    const { field: { default_value, name } } = this.props;

    switch (type) {
      case 'email':
        return <SweetInput type="email" {...fieldProps} />;
      case 'phone':
      case 'numeric':
        return <SweetInput type="tel" {...fieldProps} />;
      case 'country':
        return <SelectCountry {...fieldProps} />;
      case 'dropdown':
      case 'select':
        return <SweetSelect {...fieldProps} options={this.props.field.choices} />;
      case 'hidden':
        return <input type="hidden" name={name} value={default_value} />;
      case 'checkbox':
        return this.renderCheckbox(fieldProps);
      case 'choice':
        return this.renderChoice(fieldProps);
      case 'instruction':
        return <div className="form__instruction">{ fieldProps.label }</div>;
      case 'paragraph':
        return this.renderParagraph(fieldProps);
      case 'text':
      case 'postal':
      default:
        return <SweetInput type="text" {...fieldProps} />;
    }
  }

  render() {
    return (
      <div key={this.props.field.name} className={`MemberDetailsForm-field form__group action-form__field-container ${this.props.className || ''}`}>
        {this.renderField(this.props.field.data_type)}
      </div>
    );
  }
}
