// @flow
import React, { useState } from 'react';
import FormField from './FormField';
import type { Field } from './FormField';

export type Props = {
  id: number,
  fields: Field[],
  outstandingFields: string[],
  values: {
    [key: string]: string,
  },
};

export default function Form(props: Props) {
  const sortedFields = props.fields.sort(f => f.position);
  const [values, setValues] = useState({});

  const updateField = (name, value) => {
    values[name] = value;
    setValues(values);
  };
  const submit = () => {
    console.info('submit not implemented');
  };

  return (
    <div className="Form" id={`form-${props.id}`}>
      {sortedFields
        // filter(f => !props.values[f.name] !== 'undefined')
        .map(field => (
          <FormField
            key={field.name}
            {...field}
            onChange={value => updateField(field.name, value)}
            default_value={values[field.name] || ''}
          />
        ))}
    </div>
  );
}
