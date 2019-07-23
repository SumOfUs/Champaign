import classnames from 'classnames';
import * as React from 'react';
import { FormattedMessage } from 'react-intl';
import { useDispatch, useSelector } from 'react-redux';
import InlineConsentRadioButtons from '../../components/consent/InlineConsentRadioButtons';
import ProcessingThen from '../../components/ProcessingThen.js';
import api from '../../modules/api';
import consent from '../../modules/consent/consent';
import { updateForm } from '../../state/forms/';
import { IAppState, IFormField } from '../../types';
import Button from '../Button/Button';
import PopupMemberConsent from '../consent/PopupMemberConsent';
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
  const member = useSelector((state: IAppState) => state.member);
  const [highlightConsent, setHighlightConsent] = React.useState(false);
  const [popupOpen, setPopupOpen] = React.useState(false);
  const submitting = values['submitting'] || false;
  const className = classnames('Form', props.className);
  const country = values['country'] as string;

  const onChange = name => {
    return value => {
      dispatch(updateForm(props.id, { ...values, [name]: value }));
    };
  };

  const withConsentCheck = callback => {
    if (!consent.isRequired(country, member)) {
      return callback;
    }

    return (e: React.SyntheticEvent<HTMLFormElement>) => {
      const required =
        consent.isRequired(country, member) && values['consent'] == null;
      e.preventDefault();
      if (required) {
        setHighlightConsent(required);
        setPopupOpen(required);
      } else {
        return callback(e);
      }
    };
  };

  const onChangeConsent = value => {
    const cb = onChange('consent');
    setHighlightConsent(value === undefined);
    cb(value);
  };
  const submit = (e: React.SyntheticEvent<HTMLFormElement>) => {
    // check if consent is necessary and/or checked
    props.onSubmit(e.currentTarget);
    e.preventDefault();
  };

  const popupSubmit = (consented: boolean) => {
    onChange('consent')(consented);
    props.onSubmit();
  };

  const renderFields = (fields: IFormField[]) =>
    fields.map(field => (
      <FormField
        key={field.name}
        {...field}
        {...api.helpers.formErrorFields(props.errors[field.name])}
        onChange={onChange(field.name)}
        default_value={values[field.name] || field.default_value || ''}
      />
    ));

  return (
    <form
      onSubmit={withConsentCheck(submit)}
      className={className}
      id={`form-${props.id}`}
    >
      {renderFields(sort(filter(props.fields)))}
      {consent.isRequired(country, member) && (
        <InlineConsentRadioButtons
          consent={values['consent'] as boolean}
          onChange={onChangeConsent}
          highlight={highlightConsent}
        />
      )}
      <PopupMemberConsent
        open={popupOpen}
        countryCode={values['country'] as string}
        toggleModal={setPopupOpen}
        onSubmit={popupSubmit}
      />
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

const sort = arr => arr.sort(f => f.position);
const filter = arr => arr.filter(() => true);
