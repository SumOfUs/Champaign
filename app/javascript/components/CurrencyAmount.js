import React from 'react';
import { FormattedNumber } from 'react-intl';

const CONFIG = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

export default function CurrencyAmount(props) {
  const { currency, amount } = props;
  switch (currency) {
    case 'USD':
    case 'NZD':
    case 'CAD':
    case 'MXN':
    case 'BRL':
    case 'ARS':
    case 'AUD':
      return (
        <span style={{ pointerEvents: 'none' }}>
          {'$'}
          <FormattedNumber {...CONFIG} style="decimal" value={props.amount} />
        </span>
      );
    case 'EUR':
      return (
        <span style={{ pointerEvents: 'none' }}>
          <FormattedNumber {...CONFIG} style="decimal" value={props.amount} />
          {'€'}
        </span>
      );
    default:
      return <FormattedNumber {...CONFIG} currency={currency} value={amount} />;
  }
}
