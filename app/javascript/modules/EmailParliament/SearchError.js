// @flow
import React from 'react';
import './SearchError.css';

type Props = {
  error: boolean,
};

export default ({ error }: Props) => {
  if (!error) return null;
  return (
    <div className="SearchError has-error">
      <p>
        We couldn't find your MP. Check that your postcode is correct, or get in
        touch with us if you think there might be an issue.
      </p>
    </div>
  );
};
