const initialState = [];

export default (state = initialState, action) => {
  switch (action.type) {
    case '@@chmp:initialize':
      return action.payload.personalization.paymentMethods;
    case 'reset_member':
      return initialState;
    default:
      return state;
  }
};
