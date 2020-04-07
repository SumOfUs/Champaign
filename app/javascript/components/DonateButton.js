import React from 'react';
import Button from './Button/Button';
import CurrencyAmount from './CurrencyAmount';
import ProcessingThen from './ProcessingThen';
import { FormattedMessage } from 'react-intl';
import './DonateButton.css';

export default props => {
  let buttonString = 'fundraiser.donate';
  if (props.recurring) {
    buttonString = props.weekly
      ? 'fundraiser.donate_weekly'
      : 'fundraiser.donate_monthly';
  }

  return (
    <Button
      className="DonateButton"
      onClick={props.onClick}
      disabled={props.disabled}
    >
      <ProcessingThen processing={props.submitting || false}>
        <span className="fa fa-lock" />
        &nbsp;
        <FormattedMessage
          id={buttonString}
          defaultMessage="Donate {amount}"
          values={{
            amount: (
              <CurrencyAmount
                amount={props.amount || 0}
                currency={props.currency}
              />
            ),
          }}
        />
      </ProcessingThen>
    </Button>
  );
};
