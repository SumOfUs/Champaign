// @flow
import $ from 'jquery';
import type { FormField, InitialAction } from '../reducers';
import type { DonationBands, EnumRecurringDefault } from './helpers';

export type FundraiserInitializationOptions = {
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
  freestanding: boolean,
};

export type FundraiserAction =
  | InitialAction
  | { type: 'initialize_fundraiser', payload: FundraiserInitializationOptions }
  | { type: 'change_amount', payload: ?number }
  | { type: 'change_currency', payload: string }
  | { type: 'change_step', payload: number }
  | { type: 'preselect_amount', payload: boolean }
  | { type: 'set_donation_bands', payload: DonationBands }
  | { type: 'set_payment_type', payload: ?string }
  | { type: 'append_custom', payload: Object }
  | { type: 'set_recurring', payload: boolean }
  | { type: 'set_recurring_defaults', payload?: string }
  | { type: 'set_submitting', payload: boolean }
  | { type: 'set_store_in_vault', payload: boolean }
  | { type: 'toggle_direct_debit', payload: boolean }
  | { type: 'update_form', payload: { [key: string]: any } };

export function changeAmount(payload: ?number): FundraiserAction {
  $.publish('fundraiser:change_amount', [payload]);
  return { type: 'change_amount', payload };
}

export function changeCurrency(payload: string): FundraiserAction {
  $.publish('fundraiser:change_currency', [payload]);
  return { type: 'change_currency', payload };
}

export function appendCustom(payload: Object): FundraiserAction {
  return { type: 'append_custom', payload };
}

export function setSubmitting(payload: boolean): FundraiserAction {
  return { type: 'set_submitting', payload };
}

export function changeStep(payload: number): FundraiserAction {
  // we put it in a timeout because otherwise the event is fired before the step has switched
  setTimeout(() => $.publish('fundraiser:change_step', [payload]), 100);
  return { type: 'change_step', payload };
}

export function updateForm(payload: Object): FundraiserAction {
  return { type: 'update_form', payload };
}

export function setRecurring(payload: boolean = false): FundraiserAction {
  return { type: 'set_recurring', payload };
}

export function setStoreInVault(payload: boolean = false): FundraiserAction {
  return { type: 'set_store_in_vault', payload };
}

export function setPaymentType(payload: ?string = null): FundraiserAction {
  return { type: 'set_payment_type', payload };
}
