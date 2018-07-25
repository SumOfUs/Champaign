// @flow
import { includes } from 'lodash';
import type { InitialAction } from '../reducers';
import ee from '../../shared/pub_sub';

export type ConsentState = {
  previouslyConsented: boolean,
  isRequiredExisting: boolean,
  isRequiredNew: boolean,
  consented: ?boolean,
  countryCode: string,
  variant: string,
  modalOpen: boolean,
};

const defaultState: ConsentState = {
  previouslyConsented: false,
  isRequiredNew: false,
  isRequiredExisting: false,
  consented: null,
  countryCode: '',
  variant: 'simple',
  modalOpen: false,
};

type Action =
  | InitialAction
  | { type: '@@chmp:consent:change_consent', consented: ?boolean }
  | { type: '@@chmp:consent:change_country', countryCode: string }
  | { type: '@@chmp:consent:reset_state' }
  | { type: '@@chmp:consent:change_variant', variant: string }
  | { type: '@@chmp:consent:toggle_modal', modalOpen: boolean };

export default function reducer(
  state: ConsentState = defaultState,
  action: Action
) {
  switch (action.type) {
    case '@@chmp:initialize':
      const {
        personalization: { member, location },
      } = action.payload;
      return {
        ...state,
        countryCode: member.country || location.country || '',
        previouslyConsented: member.consented || false,
      };
    case '@@chmp:consent:change_country':
      return {
        ...state,
        countryCode: action.countryCode,
        isRequiredNew: isRequired(
          { ...state, countryCode: action.countryCode },
          c => !includes(['DE', 'AT'], c.alpha2)
        ),
        isRequiredExisting: isRequired({
          ...state,
          countryCode: action.countryCode,
        }),
      };
    case '@@chmp:consent:change_consent':
      return { ...state, consented: action.consented };
    case '@@chmp:consent:change_variant':
      return { ...state, variant: action.variant };
    case '@@chmp:consent:toggle_modal':
      return { ...state, modalOpen: action.modalOpen };
    case '@@chmp:consent:reset_state':
      return defaultState;
    default:
      return state;
  }
}

export function changeConsent(consented: ?boolean = false): Action {
  if (consented = true) {
    ee.emit('consent:change_consent:yes');
  } else {
    ee.emit('consent:change_consent:no');
  }
  return { type: '@@chmp:consent:change_consent', consented };
}

export function changeCountry(countryCode: string = ''): Action {
  return { type: '@@chmp:consent:change_country', countryCode };
}

export function changeVariant(variant: string = 'simple'): Action {
  return { type: '@@chmp:consent:change_variant', variant };
}

export function resetState(): Action {
  return { type: '@@chmp:consent:reset_state' };
}

export function toggleModal(value: boolean): Action {
  return { type: '@@chmp:consent:toggle_modal', modalOpen: value };
}

// Conditions:
// * selected country is in an affected country
// * user has not previously given consent
// * user has not selected to consent or not (`consented` is still null)
function isRequired(state: ConsentState, filter?: (country: any) => boolean) {
  const { countryCode, consented, previouslyConsented } = state;
  // Affected countries: EEA members except Germany and Austria

  const countries = window.champaign.countries
    .filter(c => c.eea_member)
    .filter(filter || (() => true))
    .map(c => c.alpha2);

  const inAffectedCountry = includes(countries, countryCode);

  return inAffectedCountry && !previouslyConsented && consented === null;
}
