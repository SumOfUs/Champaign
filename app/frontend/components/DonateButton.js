// @flow
import React from 'react';
import Button from './Button/Button';
import CurrencyAmount from './CurrencyAmount';
import LoadingThen from './LoadingThen';
import { FormattedMessage } from 'react-intl';

type OwnProps = {
  currency: string;
  amount?: number;
  loading?: boolean;
  disabled?: boolean;
  onClick: () => void;
};

export default (props: OwnProps) => (
  <Button className="DonateButton" onClick={props.onClick} disabled={props.disabled}>
    <LoadingThen loading={props.loading}>
      <span className="fa fa-lock" />&nbsp;
      <FormattedMessage
        id="fundraiser.donate"
        defaultMessage="Donate {amount}"
        values={{
          amount: (<CurrencyAmount amount={props.amount || 0} currency={props.currency} />)
        }}
      />
    </LoadingThen>
  </Button>
);
