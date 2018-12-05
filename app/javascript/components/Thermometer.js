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

  const percentage = Math.round((donations / props.goal) * 100);

  return (
    <div className="Thermometer">
      <div className="Thermometer-stats">
        <div className="Thermometer-raised">
          <FormattedMessage
            className="Thermometer-stats-label"
            id="fundraiser.thermometer.raised"
            defaultMessage="Raised"
          />
          <br />
          <span className="amount">
            <CurrencyAmount amount={donations} currency={props.currency} />
          </span>
        </div>
        <div className="Thermometer-goal">
          <FormattedMessage
            className="Thermometer-stats-label"
            id="fundraiser.thermometer.goal"
            defaultMessage="Goal"
          />
          <br />
          <span className="amount">
            <CurrencyAmount amount={props.goal} currency={props.currency} />
          </span>
        </div>
      </div>
      <div className="Thermometer-bg">
        <div
          className="Thermometer-mercury"
          style={{ width: `${percentage}%` }}
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
