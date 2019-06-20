// @flow
import React, { useState } from 'react';
import FormField from './FormField';
import type { Field } from './FormField';

export type FieldValues = {
  [key: string]: string,
};

export type Props = {
  id: number,
  fields: Field[],
  outstandingFields: string[],
  values: FieldValues,
};

export default function Form(props: Props) {
  const sortedFields = props.fields.sort(f => f.position);

  return (
    <div className="Form" id={`form-${props.id}`}>
      {sortedFields
        //.filter(f => !props.outstandingFields.includes(f.name))
        .map(field => (
          <FormField key={field.name} {...field} />
        ))}
    </div>
  );
}
