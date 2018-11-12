// @flow

export type Action =
  | { type: '@@chmp:thermometer:update', attrs: $Shape<State> }
  | { type: '@@chmp:thermometer:increment', temperature: number };

export type State = {
  donations: number,
  goal: number,
  currencyCode: string,
  // showMarkers indicates that we want the percentage markers
  // for 0, 25, 50, 75, 100 percentiles underneath the bar
  showMarkers?: boolean,
  // showPercentage indicates if the percentage should be shown
  // in the thermometer bar.
  showPercentage?: boolean,
};

const defaults: State = {
  donations: 0,
  goal: 100,
  currencyCode: 'USD',
};

export default function reducer(
  state?: State = defaults,
  action: Action
): State {
  return state;
}

export function update(attrs: $Shape<State>): Action {
  return { type: '@@chmp:thermometer:update', attrs };
}

export function increment(temperature: number): Action {
  return { type: '@@chmp:thermometer:increment', temperature };
}
