import classnames from 'classnames';
import * as React from 'react';
import { FormattedMessage } from 'react-intl';
import { useDispatch, useSelector } from 'react-redux';
import api from '../../api';
import ConsentComponent from '../../components/consent/ConsentComponent';
import ExistingMemberConsent from '../../components/consent/ExistingMemberConsent';
import ProcessingThen from '../../components/ProcessingThen.js';
import { changeCountry } from '../../state/consent/';
import { updateForm } from '../../state/forms/';
import { IAppState, IFormField } from '../../types';
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
  onValidate: (data?: any) => any;
  onSubmit: (data?: any) => any;
}

export default function Form(props: IProps, second?: any) {
  const dispatch = useDispatch();
  const values = useSelector((state: IAppState) => state.forms[props.id]);
  const submitting = values['submitting'] || false;
  const className = classnames('Form', props.className);
  const sortedFields = props.fields.sort(f => f.position);

  const onChange = name => {
    return value => {
      dispatch(updateForm(props.id, { ...values, [name]: value }));
      if (name === 'country') {
        dispatch(changeCountry(value));
      }
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
      default_value={values[field.name] || field.default_value || ''}
    />
  );

  const consentFields = () => (
    <div className="consent-container">
      <ConsentComponent />
      <ExistingMemberConsent />
    </div>
  );

  return (
    <form onSubmit={submit} className={className} id={`form-${props.id}`}>
      {sortedFields.map(field => renderFormField(field))}
      {props.enableConsent && consentFields()}
      <Button type="submit" disabled={submitting}>
        <ProcessingThen processing={submitting}>
          <FormattedMessage
            id="petition.sign_it"
            defaultMessage="Sign the petition"
          />
        </ProcessingThen>
      </Button>
    </form>
  );
}
