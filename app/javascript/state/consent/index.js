// @flow

import { includes } from 'lodash';

export type ConsentState = {
  previouslyConsented: boolean,
  consented: ?boolean,
  isDoubleOptIn: false,
  countryCode: ?string,
  email: ?string,
  isEU: false,
  memberId: ?string,
  variant: 'simple' | 'selectable-buttons' | 'scrolling',
};

const defaultState: ConsentState = {
  previouslyConsented: false,
  consented: null,
  countryCode: null,
  email: null,
  isEU: false,
  isDoubleOptIn: false,
  memberId: null,
  variant: 'simple',
};

type Action =
  | {
      type: '@@champaign:member:change_previously_consented',
      previouslyConsented: boolean,
    }
  | { type: '@@champaign:member:change_consent', consented: ?boolean }
  | { type: '@@champaign:member:change_country', countryCode: ?string }
  | { type: '@@champaign:member:change_member_email', email: ?string }
  | { type: '@@champaign:member:change_member_id', memberId: ?string }
  | { type: '@@champaign:member:change_variant', variant: string };

export default function reducer(
  state: ConsentState = defaultState,
  action: Action
) {
  switch (action.type) {
    case '@@champaign:member:change_country':
      return {
        ...state,
        countryCode: action.countryCode,
        isEU: isEU(action.countryCode),
        isDoubleOptIn: includes(['DE', 'AT'], action.countryCode),
      };
    case '@@champaign:member:change_previously_consented':
      return { ...state, previouslyConsented: action.previouslyConsented };
    case '@@champaign:member:change_consent':
      return { ...state, consented: action.consented };
    case '@@champaign:member:change_member_email':
      return { ...state, email: action.email };
    case '@@champaign:member:change_member_id':
      return { ...state, memberId: action.memberId };
    case '@@champaign:member:change_variant':
      return { ...state, variant: action.variant };
    default:
      return state;
  }
}

export function setPreviouslyConsented(previouslyConsented: boolean): Action {
  return {
    type: '@@champaign:member:change_previously_consented',
    previouslyConsented,
  };
}

export function changeConsent(consented: ?boolean = false): Action {
  return { type: '@@champaign:member:change_consent', consented };
}

export function changeCountry(countryCode: ?string = null): Action {
  return { type: '@@champaign:member:change_country', countryCode };
}

export function changeMemberEmail(email: ?string = null): Action {
  return { type: '@@champaign:member:change_member_email', email };
}

export function changeMemberId(memberId: ?string = null): Action {
  return { type: '@@champaign:member:change_member_id', memberId };
}

export function changeVariant(variant: string = 'simple'): Action {
  return { type: '@@champaign:member:change_variant', variant };
}

function isEU(countryCode: ?string, countries = window.champaign.countries) {
  const country = countries.find(c => c.alpha2 === countryCode);
  if (!country) return false;
  return country.eea_member;
}
