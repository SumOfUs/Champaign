// @flow
import React from 'react';
import { omit } from 'lodash';
import { useSelector, useDispatch } from 'react-redux';
import Form from '../../components/Form';
import Button from '../../components/Button/Button';
import WelcomeMember from '../../components/WelcomeMember/WelcomeMember';
import { resetMember } from '../../state/member/reducer';

import type { Field } from '../../components/Form/FormField';
import type { AppState } from '../../state';

type PetitionPluginConfig = {
  active: boolean,
  cta: string,
  description: string,
  fields: Field[],
  form_id: number,
  id: number,
  outstanding_fields: string[],
  page_id: number,
  target: string,
};
type Props = {
  config: PetitionPluginConfig,
  resetMember: () => void,
  onSubmit: () => void,
};

export function PetitionComponent(props: Props) {
  const dispatch = useDispatch();
  const member = useSelector((state: AppState) => state.member);

  const fields = props.config.fields.map(f => omit(f, 'id'));
  return (
    <div className="PetitionComponent">
      <WelcomeMember member={member} resetMember={props.resetMember} />
      <Form
        id={fields[0].form_id}
        fields={fields}
        outstandingFields={props.config.outstanding_fields}
        values={{}}
        onSuccess={() => console.log('successfully submitted action')}
      />
      <Button onClick={props.onSubmit}>Sign Petition</Button>
    </div>
  );
}
