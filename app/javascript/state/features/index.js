// The features store is essentially a key => value store that
// holds a list of features (keys) with their on/off values (values).
// To add a feature toggle, add a key with a default value to the defaults
// and then use FeaturesHelper to enable or disable it.

const defaults = {
  thermometer: false,
};

export default function reducer(s = defaults, a) {
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

export function enableFeature(featureName) {
  return { type: '@@chmp:feature:enable', featureName };
}

export function disableFeature(featureName) {
  return { type: '@@chmp:feature:disable', featureName };
}

// FeaturesHelper needs to be initialised with your redux store.
//   const features = new FeaturesHelper(store);
//   features.enable('featurename');
//   features.disable('featurename');
// If you try to enable or disable a feature that's not in the list
// of features (those listed in defaults), it will be ignored.
export class FeaturesHelper {
  constructor(store) {
    if (!store) throw new Error('Features must be initialised with a store.');
    this.store = store;
  }

  list() {
    return this.store.getState().features;
  }

  enable(featureName) {
    this.store.dispatch(enableFeature(featureName));
    return this.store.getState().features;
  }

  disable(featureName) {
    this.store.dispatch(disableFeature(featureName));
  }

  isEnabled(featureName) {
    const features = this.store.getState().features;
    return features[featureName] || false;
  }
}
