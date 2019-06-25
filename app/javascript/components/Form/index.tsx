// @flow
import * as React from 'react';
import { useState } from 'react';
import classnames from 'classnames';
import Button from '../Button/Button';
import FormField, { Field } from './FormField';

export type Props = {
  id: number;
  pageId: number;
  fields: Field[];
  outstandingFields: string[];
  values: { [key: string]: string };
  className?: string;
  onSuccess?: () => void;
};

export default function Form(props: Props) {
  const sortedFields = props.fields.sort(f => f.position);
  const [values, setValues] = useState({});

  const className = classnames('Form', props.className);

  const updateField = (name, value) => {
    setValues({ ...values, [name]: value });
  };

  const submit = e => {
    console.info('submit not implemented');
    e.preventDefault();
  };

  return (
    <div className={className} id={`form-${props.id}`}>
      <form onSubmit={submit}>
        {sortedFields.map(field => (
          <FormField
            key={field.name}
            {...field}
            onChange={value => updateField(field.name, value)}
            default_value={values[field.name] || field.default_value || ''}
          />
        ))}
        <Button type="submit">Sign Petition</Button>
      </form>
    </div>
  );
}
