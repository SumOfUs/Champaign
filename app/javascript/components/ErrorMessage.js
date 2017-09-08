// @flow
import React from 'react';

type Props = {
  name: string,
  error: string | string[],
};

export default function ErrorMessage(props: Props) {
  if (!props.error) return null;
  return (
    <span className="error-msg">
      {props.name} {props.error}
    </span>
  );
}
