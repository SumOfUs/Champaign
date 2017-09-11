// @flow
import React from 'react';
import { FormattedMessage } from 'react-intl';

type Props = {
  name?: string,
  errors?: React$Element<any>[],
};

export default function ErrorMessages(props: Props) {
  if (!props.errors) return null;

  return (
    <div className="ErrorMessages error-msg">
      <p>
        <span style={{ marginRight: '.25em' }}>
          <FormattedMessage
            id="errors.named_field_error"
            defaultMessage="{name} has some errors:"
            values={{ name: props.name || 'This field' }}
          />
        </span>
        {props.errors
          .map((error, i) => (
            <span key={i} className="inline-error">
              {error}
            </span>
          ))
          .reduce((prev, curr) => [prev, ', ', curr])}
      </p>
    </div>
  );
}
