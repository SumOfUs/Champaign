import { INITIAL_ACTION } from '../reducers';

export interface IFormStore {
  [formId: number]: {
    [key: string]: string | number | boolean | undefined | null;
  };
}

const initialState: IFormStore = {};
export default function formsReducer(state = initialState, action) {
  switch (action.type) {
    case '@@chmp:forms:update_form':
      return {
        ...state,
        [action.payload.id]: {
          ...state[action.payload.id],
          ...action.payload.data,
        },
      };
    case '@@chmp:forms:submitting':
      return {
        ...state,
        [action.payload.id]: {
          ...state[action.payload.id],
          submitting: action.payload.submitting,
        },
      };
    default:
      return state;
  }
}

export function updateForm(id, data) {
  return { type: '@@chmp:forms:update_form', payload: { id, data } };
}

export function setSubmitting(id, submitting: boolean) {
  return { type: '@@chmp:forms:submitting', payload: { id, submitting } };
}
