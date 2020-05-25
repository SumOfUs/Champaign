import React from 'react';
import Button from './Button/Button';
import CurrencyAmount from './CurrencyAmount';
import ProcessingThen from './ProcessingThen';
import { FormattedMessage } from 'react-intl';
import './DonateButton.css';

export default props => {
  let buttonId = 'fundraiser.donation_once';
  let buttonText = 'Donate {amount} Just Once';

  if (props.name == 'recurring' || props.recurring) {
    buttonId = 'fundraiser.donation_recurring';
    buttonText = 'Donate {amount} Monthly';
  }

  if (props.recurringDonor) {
    buttonId = 'fundraiser.donate_amount';
    buttonText = 'Donate {amount}';
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
