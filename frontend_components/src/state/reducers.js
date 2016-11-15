/* @flow */
import { combineReducers } from 'redux';
import { memberReducer as member } from './member';
import { fundraiserReducer as fundraiser } from './fundraiser/reducer';

const reducers = {
  member,
  fundraiser,
};

export default combineReducers(reducers);
