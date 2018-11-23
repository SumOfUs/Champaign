// @flow
import React from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { isEmpty, min } from 'lodash';
import CurrencyAmount from './CurrencyAmount';
import type { AppState } from '../state/reducers';
import './Thermometer.scss';

type Props =
  | {}
  | {
      active: boolean,
      currency: string,
      donations: number,
      goal: number,
      offset: number,
      remaining: number,
      title: ?string,
    };

export function Thermometer(props: Props) {
  // Only render if active
  if (isEmpty(props) || !props.active) return null;

  // Prevent overflow when donations > goal.
  const donations = min([props.donations, props.goal]);
  const remaining = props.goal - donations;

  const $remaining = (
    <CurrencyAmount amount={remaining} currency={props.currency} />
  );
  const $goal = (
    <CurrencyAmount amount={props.goal} currency={props.currency} />
  );

  return (
    <div className="Thermometer">
      <p className="Thermometer-title">{props.title}</p>
      <div className="Thermometer-stats">
        <div className="Thermometer-temperature">
          <CurrencyAmount amount={donations} currency={props.currency} />
        </div>
        <div className="Thermometer-goal">
          {remaining > 0 ? (
            <FormattedMessage
              id="fundraiser.thermometer.remaining"
              defaultMessage="{remaining} until {goal}"
              values={{ remaining: $remaining, goal: $goal }}
            />
          ) : (
            $goal
          )}
        </div>
      </div>
      <div className="Thermometer-bg">
        <div
          className="Thermometer-mercury"
          style={{
            width: `${Math.round((donations / props.goal) * 100)}%`,
          }}
        />
      </div>
    </div>
  );
}

const mapStateToProps = (state: AppState): Props => {
  const data = state.donationsThermometer;
  const currency = state.fundraiser.currency;
  if (isEmpty(data)) return {};
  return {
    active: data.active,
    currency,
    donations: data.totalDonations[currency],
    goal: data.goals[currency],
    offset: data.offset,
    title: data.title,
  };
};

export default connect(mapStateToProps)(Thermometer);
