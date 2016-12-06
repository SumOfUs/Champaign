/* @flow */
const initialState: MemberState = null;

export function memberReducer(state: MemberState = initialState, action: MemberAction): MemberState {
  switch (action.type) {
    case 'parse_champaign_data':
      if (!action.payload.member) return state;
      return { ...state, ...action.payload.member};
    case 'reset_member':
      return initialState;
    case 'set_member':
      return { ...state, ...action.payload };
    case 'update_member':
      return { ...state, ...action.payload };
    default:
      return state;
  }
}
