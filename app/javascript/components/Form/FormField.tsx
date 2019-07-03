import * as React from 'react';
import { omit } from 'lodash';
import FormGroup from './FormGroup';
import FieldTypes from './FieldTypes';

export type Choice = {
  label: string;
  value: string;
  id: string;
};

export type Field = {
  id: string; // it comes from Champaign but we omit it when passing it down
  choices: Choice[];
  data_type: string;
  default_value: string | void;
  display_mode: string;
  form_id: number;
  label: string;
  name: string;
  position: number;
  required: boolean;
  visible: boolean | void;
};

type Props = Field & {
  onChange?: (value: string | number | string[]) => void;
};
export default function FormField(props: Props) {
  const FieldType = FieldTypes[props.data_type];

  if (!FieldType) return <p>"{props.data_type}" not implemented</p>;

  return (
    <FormGroup className="FormField">
      <FieldType {...omit(props, 'id')} />
    </FormGroup>
  );
}
