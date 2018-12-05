/* @flow */
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

import type { ConsentState } from './consent';
import type { Fundraiser, EnumRecurringDefault } from './fundraiser/types';
import type { Member } from './member/reducer';
import type { PaymentMethod } from './paymentMethods/reducer';
import type { State as ExtraActionFieldsState } from './extraActionFields';
import type { State as FeaturesState } from './features';
import type { ChampaignPage, ChampaignGlobalObject } from '../types';
import type { State as donationsThermometerState } from './thermometer';

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
export type AppState = {
  +consent: ConsentState,
  +extraActionFields: ExtraActionFieldsState,
  +features: FeaturesState,
  +fundraiser: Fundraiser,
  +member: Member,
  +page: ChampaignPage,
  +paymentMethods: PaymentMethod[],
  +donationsThermometer: donationsThermometerState,
};

export default combineReducers(reducers);

export type FormField = {
  id: number,
  form_id: number,
  label: string,
  data_type: string,
  default_value: ?string,
  required: boolean,
  visible: ?boolean,
  created_at: string,
  updated_at: string,
  name: string,
  position: number,
  choices: any[],
};

export type InitialAction = {
  type: '@@chmp:initialize',
  payload: ChampaignGlobalObject,
};

export const INITIAL_ACTION = '@@chmp:initialize';
