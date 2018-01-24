// @flow
import React, { Component } from 'react';
import CurrencyAmount from '../CurrencyAmount';
import classnames from 'classnames';
import Button from '../Button/Button';
import './DonationBandButton.css';

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
      <CurrencyAmount currency={props.currency} amount={props.amount} />
    </Button>
  );
}
