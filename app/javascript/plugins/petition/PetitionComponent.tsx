import * as React from 'react';
import * as EventEmitter from 'eventemitter3';
import { useEffect } from 'react';
import { omit } from 'lodash';
import { useSelector, useDispatch } from 'react-redux';
import Form from '../../components/Form';
import Button from '../../components/Button/Button';
import WelcomeMember from '../../components/WelcomeMember/WelcomeMember';
import { resetMember } from '../../state/member/reducer';
import { Field } from '../../components/Form/FormField';
import ee from '../../shared/pub_sub';
import * as Backbone from 'backbone';

type PetitionPluginConfig = {
  active: boolean;
  cta: string;
  description: string;
  fields: Field[];
  form_id: number;
  id: number;
  outstanding_fields: string[];
  page_id: number;
  target: string;
};
type Props = {
  config: PetitionPluginConfig;
  resetMember: () => void;
  onSubmit: () => void;
  eventEmitter?: EventEmitter;
};

type Member = {
  id: number;
  email: string;
  country?: string;
  consented: boolean;
  consentedUpdatedAt: boolean;
  name?: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  welcomeName?: string;
  postal?: string;
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  actionKitUserId?: string;
} | null;
export function PetitionComponent(props: Props) {
  const dispatch = useDispatch();
  const member: Member = useSelector((state: any) => state.member);
  const fields = filterNonEmptyFields(props.config.fields, member);

  // after rendering, signal that the sidebar height may change
  useEffect(() => {
    if (props.eventEmitter) props.eventEmitter.emit('sidebar:height_change');
  });

  return (
    <div className="PetitionComponent">
      <WelcomeMember member={member} resetMember={props.resetMember} />
      <Form
        className="form--big action-form"
        pageId={(window as any).champaign.page.id}
        id={fields[0].form_id}
        fields={fields}
        outstandingFields={props.config.outstanding_fields}
        values={{}}
        onSuccess={() => console.log('successfully submitted action')}
      />
    </div>
  );
}

// TODO: Document this function and explain why we use it
const filterNonEmptyFields = (fields: Field[], member?: Member): Field[] => {
  if (!member) return fields;
  // filter out any fields that we already know from the member
  const nonEmptyFields = Object.keys(member).filter(f => member[f]);
  return fields.filter(field => !nonEmptyFields.includes(field.name));
};
