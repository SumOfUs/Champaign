import React from 'react';
import { FormattedMessage } from 'react-intl';

export default props => {
  if (props.loading) {
    return <FormattedMessage id="loading" defaultMessage="Loading..." />;
  }

  return <span>{props.children}</span>;
};
