// @flow
import type { Member } from './member/reducer';
import type { Fundraiser, EnumRecurringDefault } from './fundraiser/types';
import type { PaymentMethod } from './paymentMethods/reducer';
import type { PageAction } from './page/reducer';
import type { Config as ChampaignConfig } from './configuration';
import { combineReducers } from 'redux';
import member from './member/reducer';
import fundraiser from './fundraiser/reducer';
import paymentMethods from './paymentMethods/reducer';
import page from './page/reducer';
import config from './configuration';
import { reducer as emailTarget } from './email_pension/actions';

const reducers = {
  member,
  fundraiser,
  emailTarget,
  paymentMethods,
  page,
  config,
};

export default combineReducers(reducers);

export type AppState = {
  member: Member,
  fundraiser: Fundraiser,
  paymentMethods: PaymentMethod[],
  page: ChampaignPage,
  config: ChampaignConfig,
};

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
  type: '@champaign:data:parse',
  payload: ChampaignPersonalizationData,
};

export const INITIAL_ACTION = '@champaign:data:parse';
