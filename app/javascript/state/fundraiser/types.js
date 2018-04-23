// @flow

import type { FormField } from '../reducers';

export type DonationBands = { [id: string]: number[] };

export type EnumRecurringDefault = 'one_off' | 'recurring' | 'only_recurring';

export type FeaturedAmounts = { [id: string]: number };

export type FeaturedAmountState = {
  donationFeaturedAmount?: number,
  preselectAmount: boolean,
};

export type Fundraiser = {
  currency: string,
  currentPaymentType: PaymentType,
  currentStep: number,
  disableSavedPayments: boolean,
  directDebitOnly: boolean,
  donationAmount?: number,
  donationBands: DonationBands,
  donationFeaturedAmount?: number,
  fields: FormField[],
  form: Object,
  formId: string,
  formValues: Object,
  freestanding?: boolean,
  outstandingFields: string[],
  paymentMethods: any[],
  preselectAmount: boolean,
  recurring: boolean,
  recurringDefault: EnumRecurringDefault,
  showDirectDebit?: boolean,
  storeInVault: boolean,
  submitting: boolean,
  title: string,
};

export type FundraiserAction =
  | {
      type: '@champaign:fundraiser:init',
      payload: FundraiserInitializationOptions,
    }
  | { type: '@champaign:fundraiser:change_amount', payload: ?number }
  | { type: 'change_currency', payload: string }
  | { type: '@champaign:fundraiser:change_step', payload: number }
  | { type: 'preselect_amount', payload: boolean }
  | { type: '@champaign:fundraiser:set_direct_debit_only', payload: boolean }
  | { type: '@champaign:fundraiser:set_donation_bands', payload: DonationBands }
  | { type: '@champaign:fundraiser:set_payment_type', payload: PaymentType }
  | { type: '@champaign:fundraiser:set_recurring', payload: boolean }
  | { type: '@champaign:fundraiser:set_recurring_defaults', payload?: string }
  | { type: 'set_submitting', payload: boolean }
  | { type: '@champaign:fundraiser:set_store_in_vault', payload: boolean }
  | { type: 'toggle_direct_debit', payload: boolean }
  | { type: 'search_string_overrides', payload: { [key: string]: string } }
  | { type: 'update_form', payload: { [key: string]: any } };

export type FundraiserInitializationOptions = {
  amount: string,
  currency: string,
  donationBands: DonationBands,
  fields: FormField[],
  formValues: { [key: string]: string },
  formId: string,
  freestanding: boolean,
  outstandingFields: string[],
  pageId: string,
  preselectAmount: boolean,
  recurringDefault: EnumRecurringDefault,
  showDirectDebit: boolean,
  title: string,
};

export type PaymentType = 'card' | 'paypal' | 'gocardless';

export type RecurringState = {
  recurring: boolean,
  recurringDefault: EnumRecurringDefault,
};
