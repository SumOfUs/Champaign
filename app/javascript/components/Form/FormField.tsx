import { omit } from 'lodash';
import * as React from 'react';
import FieldTypes, { IFieldTypeProps } from './FieldTypes';
import FormGroup from './FormGroup';

export default function FormField(props: IFieldTypeProps) {
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
