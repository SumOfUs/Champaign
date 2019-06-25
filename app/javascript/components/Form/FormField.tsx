import * as React from 'react';
import { omit } from 'lodash';
import FormGroup from './FormGroup';
import FieldShape from '../FieldShape/FieldShape';
import SweetInput from '../SweetInput/SweetInput';
import SelectCountry from '../SelectCountry/SelectCountry';
import SweetSelect from '../SweetSelect/SweetSelect';
import FieldTypes from './FieldTypes';

export type Choice = {
  label: string,
  value: string,
  id: string,
};

export type Field = {
  id: string, // it comes from Champaign but we omit it here
  choices: Choice[],
  data_type: string,
  default_value: string | void,
  display_mode: 'all_members' | 'recognized_members_only' | 'new_members_only',
  form_id: number,
  label: string,
  name: string,
  position: number,
  required: boolean,
  visible: boolean | void,
};

type Props = Field & {
  onChange?: (value: string | number | string[]) => void,
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
