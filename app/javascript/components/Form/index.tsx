import classnames from 'classnames';
import * as React from 'react';
import { useState } from 'react';
import { IFormField } from '../../types';
import Button from '../Button/Button';
import FormField from './FormField';

export interface IProps {
  id: number;
  pageId: number;
  fields: IFormField[];
  outstandingFields: string[];
  values: { [key: string]: string };
  className?: string;
  onSuccess?: () => void;
}

export default function Form(props: IProps) {
  const sortedFields = props.fields.sort(f => f.position);
  const [values, setValues] = useState({});

  const className = classnames('Form', props.className);

  const updateField = name => {
    return value => {
      setValues({ ...values, [name]: value });
    };
  };

  const submit = e => {
    e.preventDefault();
  };

  const fields = sortedFields.map(field => (
    <FormField
      key={field.name}
      {...field}
      onChange={updateField(field.name)}
      default_value={values[field.name] || field.default_value || ''}
    />
  ));

  return (
    <div className={className} id={`form-${props.id}`}>
      <form onSubmit={submit}>
        {fields}
        <Button type="submit">Sign Petition</Button>
      </form>
    </div>
  );
}
