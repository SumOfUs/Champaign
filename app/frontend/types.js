/* eslint-disable */
// @flow
// temp global i18n
declare var I18n: any;
declare type ChampaignDonationBands = any;

declare type ChampaignPaymentMethod = any;

declare type ChampaignMember = {
  id: number;
  email: string;
  country: string;
  name: string;
  first_name: string;
  last_name: string;
  full_name: string;
  welcome_name: string;
  postal: string;
  actionkit_user_id: ?string;
  donor_status: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  created_at: string;
  updated_at: string;
};

declare type ChampaignLocation = {
  country: string;
  country_code: string;
  country_name: string;
  currency: string;
  ip: string;
  latitude: string;
  longitude: string;
};
declare type ChampaignPersonalizationData = {
  fundraiser: Object;
  locale: string;
  location: ChampaignLocation;
  member: ?ChampaignMember;
  paymentMethods: ChampaignPaymentMethod[];
  showDirectDebit: boolean;
  urlParams: { [key: string]: string };
};

declare type FundraiserForm = { [key: string]: any };

declare type Field = any;

declare type FundraiserState = {
  title: string;
  amount: ?number;
  currency: string;
  currencies: string[];
  donationBands: number[];
  donationAmount: ?number;
  currentStep: number;
  recurring: boolean;
  recurringDefault: 'one_off' | 'recurring' | 'only_recurring';
  storeInVault: boolean;
  paymentMethods: any[];
  currentPaymentType: ?string;
  formId: number;
  pageId: string;
  form: FundraiserForm;
  fields: { [key: string]: Field }
};

declare type InitialAction = {
  type: 'parse_champaign_data';
  payload: ChampaignPersonalizationData;
};

declare type FundraiserAction =
  InitialAction
  | { type: 'change_currency', payload: string }
  | { type: 'change_amount',  payload: ?number }
  | { type: 'set_recurring', payload: boolean }
  | { type: 'set_store_in_vault', payload: boolean }
  | { type: 'set_payment_type', payload: ?string }
  | { type: 'update_form', payload: FundraiserForm }
  | { type: 'change_step', payload: number };

declare type MemberState = {
  id: number;
  email: string;
  country?: string;
  name?: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  welcomeName?: string;
  postal?: string;
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  actionKitUserId?: string;
  createdAt?: string;
  updatedAt?: string;
} | null;

declare type MemberAction =
  InitialAction
  | { type: 'reset_member' }
  | { type: 'set_member',  payload: MemberState };

declare type AppState = {
  member: MemberState;
  fundraiser: FundraiserState;
};

declare type WebpackModuleHot = {
  accept: (path: string, callback: () => void) => void;
}
declare type WebpackModule = {
  hot: WebpackModuleHot;
};

declare var module: WebpackModule;

