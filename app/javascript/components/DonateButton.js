import React from 'react';
import Button from './Button/Button';
import CurrencyAmount from './CurrencyAmount';
import ProcessingThen from './ProcessingThen';
import { FormattedMessage } from 'react-intl';
import './DonateButton.css';

export default props => {
  let buttonId = 'fundraiser.donation_once';
  let buttonText = 'Donate {amount} Just Once';
  if (props.recurring || props.name == 'recurring') {
    if (props.weekly) {
      buttonId = 'fundraiser.donation_weekly';
      buttonText = 'Donate {amount} Weekly';
    } else {
      buttonId = 'fundraiser.donation_recurring';
      buttonText = 'Donate {amount} Monthly';
    }
  }

  return (
    <Button
      className="DonateButton"
      name={props.name}
      onClick={props.onClick}
      disabled={props.disabled}
    >
      <ProcessingThen processing={props.submitting || false}>
        <span className="fa fa-lock" />
        &nbsp;
        <FormattedMessage
          id={buttonId}
          defaultMessage={buttonText}
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
