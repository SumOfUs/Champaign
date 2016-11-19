// @flow
export function resetMember(): MemberAction {
  return { type: 'reset_member' };
}

export function setMember(payload: MemberState): MemberAction {
  return { type: 'set_member', payload };
}
