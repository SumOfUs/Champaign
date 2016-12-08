/* @flow */
import { combineReducers } from 'redux';
import { memberReducer as member } from './member';
import { fundraiserReducer as fundraiser } from './fundraiser/reducer';
import paymentMethods from './paymentMethods/reducer';

const reducers = {
  member,
  fundraiser,
  paymentMethods,
};

export default combineReducers(reducers);
