// @flow
import React, { Component } from 'react';
import { FormattedNumber } from 'react-intl';
import classnames from 'classnames';
import Button from '../Button/Button';
import './DonationBandButton.css';

const FORMATTED_NUMBER_DEFAULTS = {
  style: 'currency',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
};

type OwnProps = {
  featuredAmount?: number,
  amount: number,
  currency: string,
  onClick: () => void,
};

export default function DonationBandButton(props: OwnProps): any {
  const className = classnames({
    DonationBandButton: true,
    'DonationBandButton--highlight': props.featuredAmount === props.amount,
    'DonationBandButton--shade':
      !!props.featuredAmount && props.featuredAmount !== props.amount,
  });

  return (
    <Button className={className} onClick={props.onClick}>
      <FormattedNumber
        {...FORMATTED_NUMBER_DEFAULTS}
        currency={normalizeDollars(props.currency)}
        value={props.amount}
      />
    </Button>
  );
}

function normalizeDollars(currency: string): string {
  return ['AUD', 'CAD', 'NZD'].indexOf(currency) > -1 ? 'USD' : currency;
}
