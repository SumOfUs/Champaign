/* @flow */
import { combineReducers } from 'redux';
import member from './member/reducer';
import fundraiser from './fundraiser/reducer';
import paymentMethods from './paymentMethods/reducer';
import page from './page/reducer';
import gdpr from './gdpr';
import { reducer as emailTarget } from './email_pension/actions';

const reducers = {
  member,
  fundraiser,
  emailTarget,
  paymentMethods,
  page,
  gdpr,
};

export default combineReducers(reducers);

// import types
import type { Member } from './member/reducer';
import type { Fundraiser, EnumRecurringDefault } from './fundraiser/types';
import type { PaymentMethod } from './paymentMethods/reducer';
import type { PageAction } from './page/reducer';
import type { ConsentState } from './gdpr';

export type AppState = {
  member: Member,
  fundraiser: Fundraiser,
  paymentMethods: PaymentMethod[],
  page: ChampaignPage,
  gdpr: ConsentState,
};

type ChampaignPaymentMethod = any;

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
  type: 'parse_champaign_data',
  payload: ChampaignPersonalizationData,
};

export const INITIAL_ACTION = 'parse_champaign_data';
