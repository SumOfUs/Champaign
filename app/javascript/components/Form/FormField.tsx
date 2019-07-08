import { omit } from 'lodash';
import * as React from 'react';
import FieldTypes, { FieldTypeProps } from './FieldTypes';
import FormGroup from './FormGroup';

export default function FormField(props: FieldTypeProps) {
  const FieldType = FieldTypes[props.data_type];

  if (!FieldType) {
    return <p>"{props.data_type}" not implemented</p>;
  }

  return (
    <FormGroup className="FormField">
      <FieldType {...omit(props, 'id')} />
    </FormGroup>
  );
}
