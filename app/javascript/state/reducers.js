/*  */
import { combineReducers } from 'redux';
import member from './member/reducer';
import fundraiser from './fundraiser/reducer';
import paymentMethods from './paymentMethods/reducer';
import page from './page/reducer';
import consent from './consent';
import features from './features';
import donationsThermometer from './thermometer';
import extraActionFields from './extraActionFields';
import { reducer as emailTarget } from './email_pension/actions';

const reducers = {
  consent,
  emailTarget,
  extraActionFields,
  features,
  fundraiser,
  member,
  page,
  paymentMethods,
  donationsThermometer,
};

// type ReturnTypes = <V>((...args: any[]) => V) => V;
// export type AppState = $ObjMap<typeof reducers, ReturnTypes>;

export default combineReducers(reducers);

export const INITIAL_ACTION = '@@chmp:initialize';
