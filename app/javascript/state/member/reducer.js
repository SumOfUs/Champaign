// @flow
import type { InitialAction } from '../reducers';
import { camelCase, pick, isEmpty, mapKeys } from 'lodash';

export type Member = {
  id: number,
  email: string,
  country?: string,
  consented: boolean,
  consentedUpdatedAt: boolean,
  name?: string,
  firstName?: string,
  lastName?: string,
  fullName?: string,
  welcomeName?: string,
  postal?: string,
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor',
  registered: boolean,
  actionKitUserId?: string,
} | null;

export type MemberAction =
  | InitialAction
  | { type: 'reset_member' }
  | { type: 'update_member', payload: Member }
  | { type: 'set_member', payload: Member };

const initialState = null;
const acceptedProps = [
  'id',
  'email',
  'country',
  'consented',
  'consentedUpdatedAt',
  'name',
  'firstName',
  'lastName',
  'fullName',
  'welcomeName',
  'postal',
  'donorStatus',
  'registered',
  'actionKitUserId',
];

export default (state: Member = initialState, action: MemberAction): Member => {
  switch (action.type) {
    case '@@chmp:initialize':
      const { member } = action.payload.personalization;
      if (!member || isEmpty(member)) return initialState;
      return (
        pick(mapKeys(member, (v, k) => camelCase(k)), acceptedProps) ||
        initialState
      );
    case 'reset_member':
      return initialState;
    case 'set_member':
      return { ...state, ...action.payload };
    case 'update_member':
      return { ...state, ...action.payload };
    default:
      return state;
  }
};

export function resetMember(): MemberAction {
  return { type: 'reset_member' };
}

export function setMember(payload: Member): MemberAction {
  return { type: 'set_member', payload };
}
