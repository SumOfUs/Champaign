// @flow
import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import reducers from './reducers';
import passToLogTracker from './pass_to_log_tracker';
// flow types
export type { AppState } from './reducers';
export type { Fundraiser } from './fundraiser/types';
export type { Member } from './member/reducer';
export type { PaymentMethod } from './paymentMethods/reducer';

export default (data?: ChampaignGlobalObject): AppState => {
  const composeEnhancers =
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
  const enhancers = composeEnhancers(applyMiddleware(thunk, passToLogTracker));
  const store = createStore(reducers, {}, enhancers);

  if (data) {
    store.dispatch({
      type: '@@chmp:initialize',
      payload: data,
      skip_log: true,
    });
  }

  return store;
};
