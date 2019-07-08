import classnames from 'classnames';
import * as React from 'react';
import { useState } from 'react';
import api from '../../api/api';
import { IFormField } from '../../types';
import Button from '../Button/Button';
import FormField from './FormField';

export interface IProps {
  id: number;
  pageId: number;
  fields: IFormField[];
  outstandingFields: string[];
  values: { [key: string]: string };
  className?: string;
  onSuccess?: () => void;
}

export default function Form(props: IProps, second?: any) {
  const [formValues, setFormValues] = useState({});
  const [formErrors, setFormErrors] = useState({});

  const className = classnames('Form', props.className);
  const sortedFields = props.fields.sort(f => f.position);

  const onSuccess = () => {
    setFormErrors({});
    if (props.onSuccess) {
      props.onSuccess();
    }
  };

  const onFailure = (errors: { [field: string]: string[] }) => {
    setFormErrors(errors);
  };
  const updateField = name => {
    return value => {
      setFormValues({ ...formValues, [name]: value });
    };
  };

  const submit = (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    const form = e.currentTarget;
    api.pages
      .validateForm(props.pageId, {
        ...formValues,
        form_id: props.fields[0].form_id,
      })
      .then(r => (r.errors ? onFailure(r.errors) : onSuccess()));
  };

  const renderFormField = (field: IFormField) => (
    <FormField
      key={field.name}
      {...field}
      {...api.helpers.formErrorFields(field.name, formErrors)}
      onChange={updateField(field.name)}
      default_value={formValues[field.name] || field.default_value || ''}
    />
  );

  return (
    <div className={className} id={`form-${props.id}`}>
      <form onSubmit={submit}>
        {sortedFields.map(field => renderFormField(field))}
        <Button type="submit">Sign Petition</Button>
      </form>
    </div>
  );
}
