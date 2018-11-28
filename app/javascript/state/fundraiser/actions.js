// @flow
import ee from '../../shared/pub_sub';

import type { FundraiserAction, PaymentType, ActionFormField } from './types';

export function changeAmount(payload: ?number): FundraiserAction {
  ee.emit('fundraiser:change_amount', payload);
  return { type: 'change_amount', payload };
}

export function oneClickFailed(): FundraiserAction {
  return { type: 'one_click_failed' };
}

export function changeCurrency(payload: string): FundraiserAction {
  ee.emit('fundraiser:change_currency', payload);
  return { type: 'change_currency', payload };
}

export function setSubmitting(payload: boolean): FundraiserAction {
  return { type: 'set_submitting', payload };
}

export function changeStep(payload: number): FundraiserAction {
  // we put it in a timeout because otherwise the event is fired before the step has switched
  setTimeout(() => ee.emit('fundraiser:change_step', payload), 100);
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

export function setPaymentType(payload: PaymentType): FundraiserAction {
  return { type: 'set_payment_type', payload };
}

export function actionFormUpdated(data: ActionFormField): FundraiserAction {
  return { type: '@@chmp:action_form:updated', payload: data };
}
