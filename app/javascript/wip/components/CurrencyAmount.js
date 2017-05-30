// @flow
import React from 'react';
import { FormattedNumber } from 'react-intl';

const CONFIG = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

type OwnProps = {
  amount: number;
  currency: string;
};

export default (props: OwnProps) => (
  <FormattedNumber {...CONFIG} currency={props.currency} value={props.amount} />
);
