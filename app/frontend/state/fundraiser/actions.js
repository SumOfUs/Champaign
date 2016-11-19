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

export function updateUser(payload: FundraiserFormMember): FundraiserAction {
  return {
    type: 'update_form_member',
    payload: payload,
  };
}

export function submitDetails(details: any): Function {
  return (dispatch: Dispatch) => {

  };
}

export function submitPayment(details: any): Function {
  return (dispatch: Dispatch) => {};
}
