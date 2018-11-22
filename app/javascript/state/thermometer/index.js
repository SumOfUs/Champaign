// @flow
import type { ChampaignGlobalObject } from '../../types';
import { isEmpty, mapValues } from 'lodash';

export type Action =
  | { type: '@@chmp:initialize', payload: ChampaignGlobalObject }
  | { type: '@@chmp:thermometer:update', attrs: State }
  | { type: '@@chmp:thermometer:increment', temperature: number };

export type State =
  | {}
  | {
      active: boolean,
      goals: { [currency: string]: number },
      offset: number,
      remainingAmounts: { [currency: string]: number },
      title: ?string,
      totalDonations?: { [currency: string]: number },
    };

const defaults: State = {
  active: false,
  goals: {},
  offset: 0,
  remainingAmounts: {},
  title: '',
  totalDonations: {},
};

export default function reducer(
  state?: State = defaults,
  action: Action
): State {
  switch (action.type) {
    case '@@chmp:initialize':
      return getStateFromChampaign(action.payload);
    default:
      return state;
  }
}

export function update(attrs: State): Action {
  return { type: '@@chmp:thermometer:update', attrs };
}

export function increment(temperature: number): Action {
  return { type: '@@chmp:thermometer:increment', temperature };
}

function getStateFromChampaign(chmp: ChampaignGlobalObject): State {
  const data = chmp.personalization.donationsThermometer;
  if (isEmpty(data)) return { active: false };
  return {
    active: data.active,
    offset: data.offset,
    title: data.title,
    goals: data.goals,
    remainingAmounts: data.remaining_amounts,
    totalDonations: data.total_donations,
  };
}
