/* @flow */
const initialState: MemberState = null;

export function memberReducer(state: MemberState = initialState, action: MemberAction): MemberState {
  switch (action.type) {
    case 'reset_member':
      return initialState;
    case 'set_member':
      return { ...state, ...action.payload };
    case 'update_member':
      return { ...state, ...action.payload }
    default:
      return state;
  }
}
