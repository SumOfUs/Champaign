/* @flow */
import { combineReducers } from 'redux';
import member from './member/reducer';
import fundraiser from './fundraiser/reducer';
import paymentMethods from './paymentMethods/reducer';
import page from './page/reducer';
import { reducer as emailTarget } from './email_target/actions';

const reducers = {
  member,
  fundraiser,
  emailTarget,
  paymentMethods,
  page,
};

export default combineReducers(reducers);

// import types
import type { Member } from './member/reducer';
import type { Fundraiser, EnumRecurringDefault } from './fundraiser/helpers';
import type { PaymentMethod } from './paymentMethods/reducer';
import type { Page } from './page/reducer';

export type AppState = {
  member: Member,
  fundraiser: Fundraiser,
  paymentMethods: PaymentMethod[],
  page: Page,
};

type ChampaignPaymentMethod = any;

type ChampaignMember = {
  id: number,
  email: string,
  country: string,
  name: string,
  first_name: string,
  last_name: string,
  full_name: string,
  welcome_name: string,
  postal: string,
  actionkit_user_id: ?string,
  donor_status: 'donor' | 'non_donor' | 'recurring_donor',
  registered: boolean,
  created_at: string,
  updated_at: string,
};

declare type ChampaignLocation = {
  country: string,
  country_code: string,
  country_name: string,
  currency: string,
  ip: string,
  latitude: string,
  longitude: string,
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

type FundraiserPageOptions = {
  pageId: string,
  currency: string,
  amount: string,
  donationBands: { [key: string]: number[] },
  showDirectDebit: boolean,
  formValues: { [key: string]: string },
  formId: string,
  outstandingFields: string[],
  title: string,
  preselectAmount: boolean,
  fields: FormField[],
  recurringDefault: EnumRecurringDefault,
  freestanding: false,
};
declare type ChampaignPersonalizationData = {
  fundraiser: FundraiserPageOptions,
  locale: string,
  location: ChampaignLocation,
  member: ?ChampaignMember,
  paymentMethods: ChampaignPaymentMethod[],
  showDirectDebit: boolean,
  urlParams: { [key: string]: string },
};

export type InitialAction = {
  type: 'parse_champaign_data',
  payload: ChampaignPersonalizationData,
};

export type GlobalActions =
  | InitialAction
  | {
      type: 'querystring_parameters',
      payload: {
        recurring_default?: string,
        amount?: string,
        currency?: string,
        preselect?: string,
      },
    };

export const INITIAL_ACTION = 'parse_champaign_data';
