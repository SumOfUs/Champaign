import { isEmpty, mapValues } from 'lodash';

const defaults = {};

export default function reducer(state = defaults, action) {
  switch (action.type) {
    case '@@chmp:initialize':
      return getStateFromChampaign(action.payload);
    case '@@chmp:thermometer:update':
      return { ...state, ...action.attrs };
    default:
      return state;
  }
}

export function update(attrs) {
  return { type: '@@chmp:thermometer:update', attrs };
}

function getStateFromChampaign(chmp) {
  const data = chmp.personalization.donationsThermometer;
  if (isEmpty(data)) return {};
  return {
    active: data.active,
    offset: data.offset,
    title: data.title,
    goals: data.goals,
    remainingAmounts: data.remaining_amounts,
    totalDonations: data.total_donations,
  };
}
