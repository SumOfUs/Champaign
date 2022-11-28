import React from 'react';
import { FormattedMessage } from 'react-intl';

export function getErrorsByCode(code) {
  let errors = [];
  switch (code) {
    case '':
    case undefined:
      break;
    case '2000':
    case '2044':
    case '2046':
      errors = [<FormattedMessage id="fundraiser.bank_rejected_error" />];
      break;
    case '2005':
    case '2006':
    case '2010':
      errors = [<FormattedMessage id="fundraiser.transaction_declined" />];
      break;
    case '2001':
      errors = [
        <FormattedMessage id="fundraiser.insufficient_funds" />,
        <FormattedMessage id="fundraiser.try_again" />,
      ];
      break;
    case '2004':
      errors = [
        <FormattedMessage id="fundraiser.expired_card" />,
        <FormattedMessage id="fundraiser.try_again" />,
      ];
      break;
    case '2074':
      errors = [
        <FormattedMessage id="fundraiser.paypal_transaction_declined" />,
      ];
      break;
    default:
      errors = [<FormattedMessage id="fundraiser.unknown_error" />];
      break;
  }

  return errors;
}
