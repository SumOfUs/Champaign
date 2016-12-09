/* @flow */
import { combineReducers } from 'redux';
import member from './member/reducer';
import fundraiser from './fundraiser/reducer';
import paymentMethods from './paymentMethods/reducer';

const reducers = {
  member,
  fundraiser,
  paymentMethods,
};

export default combineReducers(reducers);
