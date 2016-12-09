// @flow
import type { Member, MemberAction } from './reducer';

export function resetMember(): MemberAction {
  return { type: 'reset_member' };
}

export function setMember(payload: Member): MemberAction {
  return { type: 'set_member', payload };
}
