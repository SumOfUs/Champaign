import { map, pick } from 'lodash';
import * as React from 'react';
import { SyntheticEvent, useState } from 'react';
import { IFormField } from '../../../types';
import SweetCheckbox from '../../Checkbox/Checkbox';
import SelectCountry from '../../SelectCountry/SelectCountry';
import SweetInput from '../../SweetInput/SweetInput';
import SweetSelect from '../../SweetSelect/SweetSelect';

export interface IFieldTypeProps extends IFormField {
  className?: string;
  errorMessage?: any;
  hasError?: boolean;
  onChange?: (value: string | number | string[]) => void;
  type?: string;
}

const basicProps = (props: IFieldTypeProps) => ({
  className: props.className,
  name: props.name,
  label: props.label,
  errorMessage: props.errorMessage,
  hasError: props.hasError,
});

const ErrorMessage = (props: IFieldTypeProps) => {
  if (!props.errorMessage) {
    return null;
  }
  return <span className="error-msg">{props.errorMessage}</span>;
};

export const Input = (props: IFieldTypeProps) => {
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

export const Email = (props: IFieldTypeProps) => {
  return <Input {...props} type="email" />;
};

export const Tel = (props: IFieldTypeProps) => {
  return <Input {...props} type="tel" />;
};

export const Choice = (props: IFieldTypeProps) => {
  const [value, setValue] = useState(props.default_value);
  const onChange = (event: SyntheticEvent<HTMLInputElement>) => {
    setValue(event.currentTarget.value);
    if (props.onChange) {
      props.onChange(event.currentTarget.value);
    }
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
              onChange={onChange}
            />
            {choice.label}
          </label>
        ))}
      <ErrorMessage {...props} />
    </div>
  );
};

export const Country = (props: IFieldTypeProps) => {
  const [value, setValue] = useState(props.default_value || '');
  const onChange = (v: string) => {
    setValue(v);
    if (props.onChange) {
      props.onChange(v);
    }
  };

  return (
    <SelectCountry {...basicProps(props)} value={value} onChange={onChange} />
  );
};

export const Select = (props: IFieldTypeProps) => {
  const [value, setValue] = useState(props.default_value || '');
  const onChange = (data: string) => {
    if (props.onChange) {
      props.onChange(data);
    }
    setValue(data);
  };
  const options = map(props.choices, choice => pick(choice, 'value', 'label'));
  const val = options.find(o => o.value === value);

  return (
    <SweetSelect
      {...basicProps(props)}
      value={val}
      onChange={onChange}
      options={options}
    />
  );
};

export const Hidden = (props: IFieldTypeProps) => {
  return (
    <input type="hidden" name={props.name} value={props.default_value || ''} />
  );
};

export const Instruction = (props: IFieldTypeProps) => {
  return (
    <div className="FormField--instruction form__instruction">
      {props.label}
    </div>
  );
};

export const Paragraph = (props: IFieldTypeProps) => {
  const [value, setValue] = useState(props.default_value);
  const onChange = (e: SyntheticEvent<HTMLTextAreaElement>) => {
    setValue(e.currentTarget.value);
    if (props.onChange) {
      props.onChange(e.currentTarget.value);
    }
  };
  return (
    <div>
      <textarea
        name={props.name}
        value={value || ''}
        placeholder={props.label}
        onChange={onChange}
        className={props.errorMessage ? 'has-error' : ''}
        maxLength={9999}
      />
      <ErrorMessage {...props} />
    </div>
  );
};

export const Checkbox = (props: IFieldTypeProps) => (
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
