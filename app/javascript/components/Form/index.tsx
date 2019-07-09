import classnames from 'classnames';
import * as React from 'react';
import { useState } from 'react';
import api from '../../api/api';
import ConsentComponent from '../../components/consent/ConsentComponent';
import ExistingMemberConsent from '../../components/consent/ExistingMemberConsent';
import { dispatchFieldUpdate } from '../../state/consent/';
import { IFormField } from '../../types';
import Button from '../Button/Button';
import FormField from './FormField';

export interface IProps {
  id: number;
  fields: IFormField[];
  outstandingFields: string[];
  values: { [key: string]: string };
  errors: { [key: string]: string[] };
  enableConsent?: boolean;
  className?: string;
  onChange: (data: any) => void;
  onValidate: (data?: any) => any;
  onSubmit: (data?: any) => any;
  onSuccess: () => void;
}

export default function Form(props: IProps, second?: any) {
  const [formValues, setFormValues] = useState(props.values || {});

  const className = classnames('Form', props.className);
  const sortedFields = props.fields.sort(f => f.position);

  const onChange = name => {
    return value => {
      const values = { ...formValues, [name]: value };
      setFormValues(values);
      props.onChange(values);
    };
  };

  const submit = (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    const form = e.currentTarget;
    props.onSubmit(form);
  };

  const renderFormField = (field: IFormField) => (
    <FormField
      key={field.name}
      {...field}
      {...api.helpers.formErrorFields(props.errors[field.name])}
      onChange={onChange(field.name)}
      default_value={formValues[field.name] || field.default_value || ''}
    />
  );

  const consentFields = () => (
    <div className="consent-container">
      <ConsentComponent />
      <ExistingMemberConsent />
    </div>
  );

  return (
    <div className={className} id={`form-${props.id}`}>
      <form onSubmit={submit}>
        {sortedFields.map(field => renderFormField(field))}
        {props.enableConsent && consentFields()}
        <Button type="submit">Sign Petition</Button>
      </form>
    </div>
  );
}
