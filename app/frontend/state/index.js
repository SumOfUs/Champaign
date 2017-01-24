// @flow
import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import reducers from './reducers';

// flow types
export type { Store } from 'redux';
export type { AppState } from './reducers';
export type { Fundraiser } from './fundraiser/reducer';
export type { Member } from './member/reducer';
export type { PaymentMethod } from './paymentMethods/reducer';
export type { Page } from './page/reducer';

export default function configureStore<AppState, A>(initialState?: AppState): Store<AppState, A> {
  const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
  return createStore(reducers, initialState, composeEnhancers(applyMiddleware(thunk)));
}
