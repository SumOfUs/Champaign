import React, { Component } from 'react';
import { map, pick } from 'lodash';
import SweetInput from '../SweetInput/SweetInput';
import SelectCountry from '../SelectCountry/SelectCountry';
import SweetSelect from '../SweetSelect/SweetSelect';
import Checkbox from '../Checkbox/Checkbox';

export default class FieldShape extends Component {
  checkboxToggle(event) {
    const checked = event.currentTarget.checked;
    this.props.onChange && this.props.onChange(checked ? '1' : '0');
  }

  fieldProps() {
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

  errorMessage(fieldProps) {
    if (fieldProps.errorMessage)
      return <span className="error-msg">{fieldProps.errorMessage}</span>;
  }

  renderParagraph(fieldProps) {
    return (
      <div>
        <textarea
          name={fieldProps.name}
          value={fieldProps.value}
          placeholder={fieldProps.label}
          onChange={e =>
            fieldProps.onChange && fieldProps.onChange(e.currentTarget.value)
          }
          className={fieldProps.errorMessage ? 'has-error' : ''}
          maxLength="9999"
        />
        {this.errorMessage(fieldProps)}
      </div>
    );
  }

  renderCheckbox(fieldProps) {
    fieldProps.value = (fieldProps.value || '0').toString();
    const checked =
      fieldProps.value === '1' ||
      fieldProps.value === 'checked' ||
      fieldProps.value === 'true';
    return (
      <div>
        <Checkbox checked={checked} onChange={this.checkboxToggle.bind(this)}>
          {fieldProps.label}
        </Checkbox>
        {this.errorMessage(fieldProps)}
      </div>
    );
  }

  renderChoice(fieldProps) {
    const { field } = this.props;
    return (
      <div className="radio-container">
        <div className="form__instruction">{fieldProps.label}</div>
        {field.choices &&
          field.choices.map(choice => (
            <label key={choice.id} htmlFor={choice.id}>
              <input
                id={choice.id}
                name={fieldProps.name}
                type="radio"
                value={choice.value}
                checked={choice.value === fieldProps.value}
                onChange={event =>
                  this.props.onChange &&
                  this.props.onChange(event.currentTarget.value)
                }
              />
              {choice.label}
            </label>
          ))}
        {this.errorMessage(fieldProps)}
      </div>
    );
  }

  renderField(type) {
    const fieldProps = this.fieldProps();
    const {
      field: { default_value, name, choices },
    } = this.props;

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
        return (
          <SweetSelect
            {...fieldProps}
            options={map(choices, c => pick(c, 'value', 'label'))}
          />
        );
      case 'hidden':
        return <input type="hidden" name={name} value={default_value} />;
      case 'checkbox':
        return this.renderCheckbox(fieldProps);
      case 'choice':
        return this.renderChoice(fieldProps);
      case 'instruction':
        return <div className="form__instruction">{fieldProps.label}</div>;
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
      <div
        key={this.props.field.name}
        className={`MemberDetailsForm-field form__group action-form__field-container ${this
          .props.className || ''}`}
      >
        {this.renderField(this.props.field.data_type)}
      </div>
    );
  }
}
