import React from 'react';
import Button from './Button/Button';
import CurrencyAmount from './CurrencyAmount';
import ProcessingThen from './ProcessingThen';
import { FormattedMessage } from 'react-intl';
import './DonateButton.css';

export default props => (
  <Button
    className="DonateButton"
    onClick={props.onClick}
    disabled={props.disabled}
  >
    <ProcessingThen processing={props.submitting || false}>
      <span className="fa fa-lock" />
      &nbsp;
      <FormattedMessage
        id={
          props.recurring
            ? 'fundraiser.donate_every_month'
            : 'fundraiser.donate_once'
        }
        defaultMessage={props.recurring ? 'Monthly' : 'Just once'}
        // values={{
        //   amount: (
        //     <CurrencyAmount
        //       amount={props.amount || 0}
        //       currency={props.currency}
        //     />
        //   ),
        // }}
      />
    </ProcessingThen>
  </Button>
);
