// @flow
import type { InitialAction } from '../reducers';
import type { AppState } from '../';
import type { Store } from 'redux';

export type State = {
  googlepay: boolean,
};

const defaults: State = {
  googlepay: false,
};

type Action =
  | InitialAction
  | { type: '@@chmp:feature:enable', featureName: string }
  | { type: '@@chmp:feature:disable', featureName: string };

export default function reducer(s: State = defaults, a: Action): State {
  switch (a.type) {
    case '@@chmp:feature:enable':
      if (Object.keys(s).includes(a.featureName)) {
        return { ...s, [a.featureName]: true };
      }
      break;
    case '@@chmp:feature:disable':
      if (Object.keys(s).includes(a.featureName)) {
        return { ...s, [a.featureName]: false };
      }
      break;
    default:
      return s;
  }
  return s;
}

export function enableFeature(featureName: string): Action {
  return { type: '@@chmp:feature:enable', featureName };
}

export function disableFeature(featureName: string): Action {
  return { type: '@@chmp:feature:disable', featureName };
}

export class FeaturesHelper {
  store: Store<AppState, Action>;
  constructor(store: Store<AppState, Action>) {
    if (!store) throw new Error('Features must be initialised with a store.');
    this.store = store;
  }

  list(): State {
    return this.store.getState().features;
  }

  enable(featureName: string) {
    this.store.dispatch(enableFeature(featureName));
    return this.store.getState().features;
  }

  disable(featureName: string) {
    this.store.dispatch(disableFeature(featureName));
  }

  isEnabled(featureName: string): boolean {
    const features = this.store.getState().features;
    return features[featureName] || false;
  }
}
