import type { FormAction } from './reducer';

export function updateForm(id: string, data: any): FormAction {
  return { type: 'update_form', payload: { id, data } };
}
