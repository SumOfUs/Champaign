/* @flow */

declare type FundraiserAction =
  { type: 'change_currency', payload: string }
  | { type: 'change_amount',  payload: ?number }
  | { type: 'change_step', payload: number };

declare type FundraiserState = {
  amount: ?number;
  currency: string;
  currencies: string[];
  donationBands: number[];
  donationAmount: ?number;
  currentStep: number;
  recurring: boolean;
  storeInVault: boolean;
  formId: ?number;
};

declare type MemberState = {
  id: number;
  email: string;
  country: ?string;
  firstName: ?string;
  lastName: ?string;
  fullName: ?string;
  welcomeName: ?string;
  postal: ?string;
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  actionKitUserId: ?string;
  createdAt: ?string;
  updatedAt: ?string;
} | null;

declare type MemberAction =
  { type: 'reset_member' }
  | { type: 'set_member',  payload: MemberState };

declare type AppState = {
  member: MemberState;
  fundraiser: FundraiserState;
};
