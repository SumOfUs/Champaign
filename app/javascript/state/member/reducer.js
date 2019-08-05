import { camelCase, pick, isEmpty, mapKeys } from 'lodash';

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
  'more',
];

export default (state = initialState, action) => {
  switch (action.type) {
    case '@@chmp:initialize':
      const { member } = action.payload.personalization;
      if (!member || isEmpty(member)) return initialState;
      return (
        pick(mapKeys(member, (v, k) => camelCase(k)), acceptedProps) ||
        initialState
      );
    case 'reset_member':
      // also reset global object:
      window.champaign.personalization.member = {};
      return initialState;
    case 'set_member':
      return { ...state, ...action.payload };
    case 'update_member':
      return { ...state, ...action.payload };
    default:
      return state;
  }
};

export function resetMember() {
  return { type: 'reset_member' };
}

export function setMember(payload) {
  return { type: 'set_member', payload };
}
