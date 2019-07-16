import * as EventEmitter from 'eventemitter3';
import * as React from 'react';
import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import Form from '../../components/Form';
import WelcomeMember from '../../components/WelcomeMember/WelcomeMember';
import { IFormField } from '../../types';
import { IChampaignMember, IPetitionPluginConfig } from '../../window';
import './PetitionComponent.css';

interface IProps {
  config: IPetitionPluginConfig;
  values: { [key: string]: any };
  errors: { [key: string]: string[] };
  resetMember: () => void;
  onFormChange: (data: any) => void;
  onSubmit: (data?: any) => void;
  onValidate: (data?: any) => void;
  prefillValues: (data: any) => void;
  eventEmitter?: EventEmitter;
}

export function PetitionComponent(props: IProps) {
  const dispatch = useDispatch();
  const member: IChampaignMember = useSelector((state: any) => state.member);
  const fields = filterNonEmptyFields(props.config.fields, member);
  let data = {};
  data = assignValuestoKnownField(props.config.fields, member, data);
  if (member) {
    props.prefillValues(data);
  }
  // after rendering, signal that the sidebar height may change
  useEffect(() => {
    setTimeout(() => {
      if (props.eventEmitter) {
        props.eventEmitter.emit('sidebar:height_change');
      }
    }, 1000);
  });

  // tslint:disable-next-line: no-console
  const onSuccess = () => console.log('successfully submitted action');

  return (
    <div className="PetitionComponent">
      <WelcomeMember member={member} resetMember={props.resetMember} />
      <Form
        className="form--big action-form"
        id={props.config.form_id}
        fields={fields}
        outstandingFields={props.config.outstanding_fields}
        values={props.values}
        errors={props.errors}
        enableConsent={true}
        onChange={props.onFormChange}
        onValidate={props.onValidate}
        onSubmit={props.onSubmit}
        onSuccess={onSuccess}
      />
    </div>
  );
}

// TODO: Document this function and explain why we use it
const filterNonEmptyFields = (
  fields: IFormField[],
  member?: IChampaignMember
): IFormField[] => {
  if (!member) {
    return fields;
  }
  // filter out any fields that we already know from the member
  const nonEmptyFields = Object.keys(member).filter(f => member[f]);
  return fields.filter(field => !nonEmptyFields.includes(field.name));
};

const assignValuestoKnownField = (
  fields: IFormField[],
  member: IChampaignMember,
  data: any
) => {
  if (member) {
    fields.filter(field => {
      if (member[field.name]) {
        data[field.name] = member[field.name];
      }
    });
  }
  return data;
};
