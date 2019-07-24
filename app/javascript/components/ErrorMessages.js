import React from 'react';
import { isArray } from 'lodash';
import { FormattedMessage } from 'react-intl';

export default function ErrorMessages(props) {
  if (!props.errors) return null;
  const { errors } = props;
  const name = props.name || (
    <FormattedMessage id="errors.this_field" defaultMessage="This field" />
  );
  let message = '';

  if (isArray(errors)) {
    message = errors
      .map((error, i) => (
        <span key={i} className="inline-error">
          {error}
        </span>
      ))
      .reduce((prev, curr) => [prev, ', ', curr]);
  } else {
    message = <span className="inline-error">{errors}</span>;
  }

  return (
    <div className="ErrorMessages error-msg">
      <p>
        <span>{name}</span> {message}.
      </p>
    </div>
  );
}
