import React from 'react';
import { FormattedMessage } from 'react-intl';

export default props => {
  if (props.processing) {
    return <FormattedMessage id="processing" defaultMessage="Processing..." />;
  }

  return <span>{props.children}</span>;
};
