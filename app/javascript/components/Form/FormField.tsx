import { omit } from 'lodash';
import * as React from 'react';
import { IFormField } from '../../types';
import FieldTypes from './FieldTypes';
import FormGroup from './FormGroup';

type Props = IFormField & {
  onChange?: (value: string | number | string[]) => void;
};
export default function FormField(props: Props) {
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
