type PaymentMethod = {
  id: number;
  token: string;
  instrument_type: string;
  card_type?: string;
  email?: string;
  last_4?: string;
};

const initialState: PaymentMethod[] = [];

export default (state: PaymentMethod[] = initialState, action: any): PaymentMethod[] => {
  switch (action.type) {
    case 'parse_champaign_data':
      return action.payload.paymentMethods;
    default:
      return state;
  }
};
