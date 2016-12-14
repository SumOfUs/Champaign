// @flow
import React from 'react';
import Button from './Button/Button';
import CurrencyAmount from './CurrencyAmount';
import LoadingThen from './LoadingThen';
import { FormattedMessage } from 'react-intl';
import './DonateButton.css';

type OwnProps = {
  currency: string;
  amount?: number;
  loading?: boolean;
  recurring?: boolean;
  disabled?: boolean;
  onClick: () => void;
};

export default (props: OwnProps) => (
  <Button className="DonateButton" onClick={props.onClick} disabled={props.disabled}>
    <LoadingThen loading={props.loading}>
      <span className="fa fa-lock" />&nbsp;
      <FormattedMessage
        id={ props.recurring ? 'fundraiser.donate_monthly' : 'fundraiser.donate' }
        defaultMessage="Donate {amount}"
        values={{
          amount: (<CurrencyAmount amount={props.amount || 0} currency={props.currency} />)
        }}
      />
    </LoadingThen>
  </Button>
);
