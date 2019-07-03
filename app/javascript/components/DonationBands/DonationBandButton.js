import React, { Component } from 'react';
import CurrencyAmount from '../CurrencyAmount';
import classnames from 'classnames';
import Button from '../Button/Button';
import './DonationBandButton.css';

export default function DonationBandButton(props) {
  const className = classnames({
    DonationBandButton: true,
    'DonationBandButton--highlight': props.featuredAmount === props.amount,
    'DonationBandButton--shade':
      !!props.featuredAmount && props.featuredAmount !== props.amount,
  });

  return (
    <Button className={className} onClick={props.onClick}>
      <CurrencyAmount currency={props.currency} amount={props.amount} />
    </Button>
  );
}
