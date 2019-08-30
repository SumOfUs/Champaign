import ee from '../../shared/pub_sub';

export function changeAmount(payload) {
  ee.emit('fundraiser:change_amount', payload);
  return { type: 'change_amount', payload };
}

export function oneClickFailed() {
  return { type: 'one_click_failed' };
}

export function changeCurrency(payload) {
  ee.emit('fundraiser:change_currency', payload);
  return { type: 'change_currency', payload };
}

export function setSubmitting(payload) {
  return { type: 'set_submitting', payload };
}

export function changeStep(payload) {
  // we put it in a timeout because otherwise the event is fired before the step has switched
  setTimeout(() => ee.emit('fundraiser:change_step', payload), 100);
  return { type: 'change_step', payload };
}

export function updateForm(payload) {
  return { type: 'update_form', payload };
}

export function setRecurring(payload = false) {
  return { type: 'set_recurring', payload };
}

export function setStoreInVault(payload = false) {
  return { type: 'set_store_in_vault', payload };
}

export function setPaymentType(payload) {
  return { type: 'set_payment_type', payload };
}

export function actionFormUpdated(data) {
  return { type: '@@chmp:action_form:updated', payload: data };
}
