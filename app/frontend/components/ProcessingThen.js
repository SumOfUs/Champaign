// @flow
import React from 'react';
import { FormattedMessage } from 'react-intl';

export default (props: {processing: boolean, children?: React$Element<any>}) => {
  if (props.processing) {
    return <FormattedMessage id="processing" defaultMessage="Processing..." />;
  }

  return <span>{ props.children }</span>;
};
