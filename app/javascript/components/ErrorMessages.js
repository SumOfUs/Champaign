// @flow
import React from 'react';
import { FormattedMessage } from 'react-intl';

type Props = {
  name?: any,
  errors?: any[],
};

export default function ErrorMessages(props: Props): React$Node<*> | null {
  if (!props.errors) return null;
  const name = props.name || (
    <FormattedMessage id="errors.this_field" defaultMessage="This field" />
  );

  return (
    <div className="ErrorMessages error-msg">
      <p>
        <span>{props.name} </span>
        {props.errors
          .map((error, i) => (
            <span key={i} className="inline-error">
              {error}
            </span>
          ))
          .reduce((prev, curr) => [prev, ', ', curr])}
        .
      </p>
    </div>
  );
}
