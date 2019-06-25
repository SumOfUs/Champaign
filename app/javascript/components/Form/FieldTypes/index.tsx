// @flow
import * as React from 'react';
import { SyntheticEvent } from 'react';
import { useState } from 'react';
import { map, pick } from 'lodash';
import SweetInput from '../../SweetInput/SweetInput';
import SelectCountry from '../../SelectCountry/SelectCountry';
import SweetSelect from '../../SweetSelect/SweetSelect';
import SweetCheckbox from '../../Checkbox/Checkbox';
import { Field } from '../FormField';

export type Props = Field & {
  className?: string,
  errorMessage?: any,
  hasError?: boolean,
  onChange?: (value: string) => void,
  type: string,
};

const basicProps = (props: Props) => ({
  className: props.className,
  name: props.name,
  label: props.label,
  errorMessage: props.errorMessage,
  hasError: props.hasError,
});

const ErrorMessage = (props: Props) => {
  if (!props.errorMessage) return null;
  return <span className="error-msg">{props.errorMessage}</span>;
};

export const Input = (props: Props) => {
  const onChange = (v: string) => {
    if (props.onChange) {
      props.onChange(v);
    }
  };
  return (
    <SweetInput
      {...basicProps(props)}
      onChange={onChange}
      required={props.required}
      type={props.type || 'text'}
      value={props.default_value || ''}
    />
  );
};

export const Email = (props: Props) => {
  return <Input {...props} type="email" />;
};

export const Tel = (props: Props) => {
  return <Input {...props} type="tel" />;
};

export const Choice = (props: Props) => {
  const [value, setValue] = useState(props.default_value);
  const onChange = (v: string) => {
    setValue(v);
    if (props.onChange) props.onChange(v);
  };
  return (
    <div className="radio-container">
      <div className="form__instruction">{props.label}</div>
      {props.choices &&
        props.choices.map(choice => (
          <label key={choice.id} htmlFor={choice.id}>
            <input
              id={choice.id}
              name={props.name}
              type="radio"
              value={choice.value}
              checked={choice.value === value}
              onChange={(event: SyntheticEvent<HTMLInputElement>) =>
                onChange(event.currentTarget.value)
              }
            />
            {choice.label}
          </label>
        ))}
      <ErrorMessage {...props} />
    </div>
  );
};

export const Country = (props: Props) => {
  const [value, setValue] = useState(props.default_value);
  const onChange = (v: string) => {
    setValue(v);
    if (props.onChange) props.onChange(v);
  };

  return (
    <SelectCountry {...basicProps(props)} value={value} onChange={onChange} />
  );
};

const Select = (props: Props) => {
  const [value, setValue] = useState(props.default_value);
  const onChange = (v: string) => {
    setValue(v);
    if (props.onChange) props.onChange(v);
  };
  const options = map(props.choices, choice => pick(choice, 'value', 'label'));

  return (
    <SweetSelect
      {...basicProps(props)}
      value={value}
      onChange={onChange}
      options={options}
    />
  );
};

const Hidden = (props: Props) => {
  return (
    <input type="hidden" name={props.name} value={props.default_value || ''} />
  );
};

const Instruction = (props: Props) => {
  return (
    <div className="FormField--instruction form__instruction">
      {props.label}
    </div>
  );
};

const Paragraph = (props: Props) => {
  const [value, setValue] = useState(props.default_value);
  const onChange = (v: string) => {
    setValue(v);
    if (props.onChange) props.onChange(v);
  };
  return (
    <div>
      <textarea
        name={props.name}
        value={value || ''}
        placeholder={props.label}
        onChange={(e: SyntheticEvent<HTMLTextAreaElement>) =>
          onChange(e.currentTarget.value)
        }
        className={props.errorMessage ? 'has-error' : ''}
        maxLength={9999}
      />
      <ErrorMessage {...props} />
    </div>
  );
};

const Checkbox = (props: Props) => (
  <SweetCheckbox {...props}>{props.label}</SweetCheckbox>
);

export default {
  checkbox: Checkbox,
  choice: Choice,
  email: Email,
  numeric: Tel,
  phone: Tel,
  postal: Input,
  text: Input,
  country: Country,
  dropdown: Select,
  select: Select,
  hidden: Hidden,
  instruction: Instruction,
  paragraph: Paragraph,
};
