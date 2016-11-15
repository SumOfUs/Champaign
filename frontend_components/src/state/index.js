// @flow
import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import reducers from './reducers';

type IState = {[key: string]: mixed};

export default function configureStore(initialState: IState = {}): Store {
  const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
  return createStore(reducers, initialState, composeEnhancers(applyMiddleware(thunk)));
}
