// @flow
export type PaymentMethod = {
  id: number,
  token: string,
  instrument_type: string,
  card_type?: string,
  email?: string,
  last_4?: string,
};

const initialState: PaymentMethod[] = [];

export default (
  state: PaymentMethod[] = initialState,
  action: any
): PaymentMethod[] => {
  switch (action.type) {
    case '@@chmp:initialize':
      return action.payload.personalization.paymentMethods;
    case 'reset_member':
      return initialState;
    default:
      return state;
  }
};
