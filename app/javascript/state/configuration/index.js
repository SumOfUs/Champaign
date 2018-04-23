// @flow
import { mapKeys, camelCase } from 'lodash'

export type Config = {
  braintreeTokenUrl: string,
};

const defaults = {
  braintreeTokenUrl: '',
};

export default function reducer(state: Config = defaults, action: any): Config {
  switch (action.type) {
    case '@champaign:config:init':
      return mapKeys(action.payload, (v, k) => camelCase(k));
    default:
      return state;
  }
}
