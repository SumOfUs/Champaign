import React from 'react';
import Button from './Button/Button';
import CurrencyAmount from './CurrencyAmount';
import ProcessingThen from './ProcessingThen';
import { FormattedMessage } from 'react-intl';
import './DonateButton.css';

export default props => (
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
        id={
          props.name == 'recurring'
            ? 'fundraiser.donation_recurring'
            : 'fundraiser.donation_once'
        }
        defaultMessage={props.name == 'recurring' ? 'Monthly' : 'Just Once'}
      />
    </ProcessingThen>
  </Button>
);
