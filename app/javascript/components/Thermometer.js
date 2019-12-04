import React from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { isEmpty, min } from 'lodash';
import CurrencyAmount from './CurrencyAmount';
import './Thermometer.scss';

export function Thermometer(props) {
  // Only render if active
  if (isEmpty(props) || !props.active) return null;
  console.log('PROPS:', props);
  const currency = props.currency;
  const goal = props.goals[currency];

  // Prevent overflow when donations > goal.
  const donations = min([
    props.total_donations[currency],
    props.goals[currency],
  ]);

  const percentage = Math.round((donations / goal) * 100);

  if (goal === 0) return null;

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
            <CurrencyAmount amount={donations} currency={currency} />
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
            <CurrencyAmount amount={goal} currency={currency} />
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

const mapStateToProps = state => {
  const data = state.donationsThermometer;
  const currency = state.fundraiser.currency;
  if (isEmpty(data)) return {};
  return {
    active: data.active,
    currency,
    total_donations: data.totalDonations,
    goals: data.goals,
    offset: data.offset,
    title: data.title,
  };
};

export default connect(mapStateToProps)(Thermometer);
