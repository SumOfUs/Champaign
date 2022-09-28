import React from 'react';
import CurrencyAmount from './CurrencyAmount';
import ProcessingThen from './ProcessingThen';
import { FormattedMessage } from 'react-intl';
import classNames from 'classnames';
import './DonateLink.css';

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

  if (props.recurringDonor) {
    buttonId = 'fundraiser.donate_amount';
    buttonText = 'Donate {amount}';
  }
  const className = classNames(
    'DonateLink',
    props.disabled ? 'disabled' : '',
    props.className ? props.className : ''
  );
  return (
    <button
      id={props.id}
      className={className}
      name={props.name}
      disabled={props.disabled}
      onClick={props.disabled ? null : props.onClick}
    >
      <ProcessingThen processing={props.submitting || false}>
        {'Or'}
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
    </button>
  );
};
