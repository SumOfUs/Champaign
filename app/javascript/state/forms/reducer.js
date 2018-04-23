// @flow
import type { InitialAction, FormField } from '../reducers';
import { INITIAL_ACTION } from '../reducers';

export type Form = {
  fields: FormField[],
  values: Object,
};

export type Forms = { [id: string]: Form };
export type FormAction =
  | InitialAction
  | { type: 'update_form', payload: { id: string, data: any } };

export default function formsReducer(
  state: Forms = {},
  action: FormAction
): Forms {
  switch (action.type) {
    case INITIAL_ACTION:
      return state;
    case 'update_form':
      return { ...state, [action.payload.id]: action.payload.data };
    default:
      return state;
  }
}
