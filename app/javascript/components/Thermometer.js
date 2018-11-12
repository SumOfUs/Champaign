// @flow
import React from 'react';
import CurrencyAmount from './CurrencyAmount';
import './Thermometer.css';
import type { AppState } from '../state/reducers';

type Props = {
  donations: number,
  goal: number,
  currencyCode: string,
  color?: string,
};

export default function Thermometer(props: Props) {
  const mercuryStyle = {
    backgroundColor: props.color || '#00c0cf',
    width: `${Math.round((props.donations / props.goal) * 100)}%`,
  };

  return (
    <div className="Thermometer">
      <div className="Thermometer-stats">
        <div className="Thermometer-temperature">
          <CurrencyAmount
            amount={props.donations}
            currency={props.currencyCode}
          />
        </div>
        <div className="Thermometer-goal">
          <CurrencyAmount amount={props.goal} currency={props.currencyCode} />
        </div>
      </div>
      <div className="Thermometer-bg">
        <div className="Thermometer-mercury" style={mercuryStyle} />
      </div>
    </div>
  );
}
