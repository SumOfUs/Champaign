// @flow

export function changeAmount(payload: ?number): FundraiserAction {
  return { type: 'change_amount', payload };
}

export function changeCurrency(payload: string): FundraiserAction {
  return { type: 'change_currency', payload };
}

export function changeStep(payload: number): FundraiserAction {
  return { type: 'change_step', payload };
}

export function updateForm(payload: FundraiserFormMember): FundraiserAction {
  return {
    type: 'update_form',
    payload: payload,
  };
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

export function submitDetails(details: any): Function {
  return (dispatch: Dispatch) => {

  };
}

export function submitPayment(details: any): Function {
  return (dispatch: Dispatch) => {};
}
