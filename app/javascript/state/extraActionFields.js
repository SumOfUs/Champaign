// @flow
import { omit } from 'lodash';
import ee from '../shared/pub_sub';

type ActionValue = string | number | boolean;
export type State = { [fieldName: string]: ActionValue };
type Action =
  | { type: '@@chmp:extra_action_fields:add', fields: State }
  | { type: '@@chmp:extra_action_fields:remove', fieldNames: string[] }
  | { type: '@@chmp:extra_action_fields:clear' };

export default function extraActionFieldsReducer(
  state: State = {},
  action: Action
): State {
  switch (action.type) {
    case '@@chmp:extra_action_fields:add':
      return { ...state, ...action.fields };
    case '@@chmp:extra_action_fields:remove':
      return omit(state, ...action.fieldNames);
    case '@@chmp:extra_action_fields:clear':
      return {};
    default:
      return state;
  }
}

export function addExtraActionFields(fields: State): Action {
  return { type: '@@chmp:extra_action_fields:add', fields };
}
if (!ee.listeners('@@chmp:extra_action_fields:add').length) {
  ee.on('@@chmp:extra_action_fields:add', function(fields: State) {
    const store = window.champaign.store;
    if (store) {
      store.dispatch(addExtraActionFields(fields));
    }
  });
}

export function removeExtraActionFields(...fieldNames: string[]): Action {
  return { type: '@@chmp:extra_action_fields:remove', fieldNames };
}
if (!ee.listeners('@@chmp:extra_action_fields:remove').length) {
  ee.on('@@chmp:extra_action_fields:remove', function(...fields: string[]) {
    const store = window.champaign.store;
    if (store) store.dispatch(removeExtraActionFields(...fields));
  });
}

export function clearExtraActionFields(): Action {
  return { type: '@@chmp:extra_action_fields:clear' };
}
if (!ee.listeners('@@chmp:extra_action_fields:clear').length) {
  ee.on('@@chmp:extra_action_fields:clear', function() {
    const store = window.champaign.store;
    if (store) store.dispatch(clearExtraActionFields());
  });
}
