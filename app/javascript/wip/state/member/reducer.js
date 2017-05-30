// @flow
import type { InitialAction } from '../reducers';

export type Member = {
  id: number;
  email: string;
  country?: string;
  name?: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  welcomeName?: string;
  postal?: string;
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  actionKitUserId?: string;
  createdAt?: string;
  updatedAt?: string;
} | null;

export type MemberAction =
  InitialAction
  | { type: 'reset_member' }
  | { type: 'set_member',  payload: Member };

const initialState: Member = null;

export default (state: Member = initialState, action: MemberAction): Member => {
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
};
