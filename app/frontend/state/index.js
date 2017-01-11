// @flow
import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import reducers from './reducers';

// flow types
export type { Store } from 'redux';
export type { FundraiserState } from './fundraiser/reducer';
export type { Member } from './member/reducer';
export type { PaymentMethod } from './paymentMethods/reducer';
export type { AppState } from './reducers';

export default function configureStore<S, A>(initialState?: S): Store<S, A> {
  const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
  return createStore(reducers, initialState, composeEnhancers(applyMiddleware(thunk)));
}
