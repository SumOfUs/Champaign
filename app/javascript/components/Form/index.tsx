// @flow
import * as React from 'react';
import { useState } from 'react';
import classnames from 'classnames';
import FormField, { Field } from './FormField';
import { className } from 'postcss-selector-parser';

export type Props = {
  id: number,
  fields: Field[],
  outstandingFields: string[],
  values: { [key: string]: string },
  className?: string,
  onSuccess?: () => void,
};

export default function Form(props: Props) {
  const sortedFields = props.fields.sort(f => f.position);
  const [values, setValues] = useState({});

  const className = classnames('Form', props.className);

  const updateField = (name, value) => {
    setValues({ ...values, [name]: value });
  };
  const submit = () => {
    console.info('submit not implemented');
  };

  return (
    <div className={className} id={`form-${props.id}`}>
      {sortedFields
        // filter(f => !props.values[f.name] !== 'undefined')
        .map(field => (
          <FormField
            key={field.name}
            {...field}
            onChange={value => updateField(field.name, value)}
            default_value={values[field.name] || field.default_value || ''}
          />
        ))}
    </div>
  );
}
