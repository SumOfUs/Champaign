export function updateForm(id, data) {
  return { type: 'update_form', payload: { id, data } };
}
