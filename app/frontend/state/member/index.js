/* @flow */
const initialState: MemberState = null;

export function memberReducer(state: MemberState = initialState, action: MemberAction): MemberState {
  switch (action.type) {
    case 'parse_champaign_data':
      if (!action.payload.member) return state;

      const m = action.payload.member;
      const member: MemberState = {
        id: m.id,
        email: m.email,
        country: m.country,
        name: m.name,
        firstName: m.first_name,
        lastName: m.last_name,
        fullName: m.full_name,
        welcomeName: m.welcome_name,
        postal: m.postal,
        donorStatus: m.donor_status,
        registered: m.registered,
        actionKitUserId: m.actionkit_user_id,
        createdAt: m.created_at,
        updatedAt: m.updated_at,
      };
      return { ...state, ...member};
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
