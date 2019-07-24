import { INITIAL_ACTION } from '../reducers';

export default function formsReducer(state = {}, action) {
  switch (action.type) {
    case INITIAL_ACTION:
      return state;
    case 'update_form':
      return { ...state, [action.payload.id]: action.payload.data };
    default:
      return state;
  }
}
