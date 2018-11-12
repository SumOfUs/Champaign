// @flow
import { update, increment } from '../state/thermometer';
import type { Store } from 'redux';
import type { AppState } from '../state/reducers';
import type { Action, State } from '../state/thermometer';

type Config = {
  store: Store<AppState, Action>,
  attrs: State,
};

// Creates a thermometer with a unique id (uuid/v4) and syncs it to the store.
export class Thermometer {
  store: Store<AppState, Action>;

  constructor(options: Config) {
    this.store = options.store;
    this.store.dispatch(update(options.attrs));
  }

  attrs() {
    return this.store.getState().fundraisingThermometer;
  }

  update(attrs: $Shape<State>) {
    this.store.dispatch(update(attrs));
  }

  increment(donation: number) {
    this.store.dispatch(increment(donation));
  }
}

const myThermometer = new Thermometer({
  store: window.champaign.store,
  attrs: {
    donations: 0,
    goal: 100,
    currencyCode: 'GBP',
  },
});
