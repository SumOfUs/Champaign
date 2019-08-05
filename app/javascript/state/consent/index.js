import { includes } from 'lodash';
import EEA_LIST from '../../shared/eea-list';

const defaultState = {
  previouslyConsented: false,
  isRequiredNew: false,
  isRequiredExisting: false,
  consented: null,
  countryCode: '',
  variant: 'simple',
  modalOpen: false,
  showConsentRequired: false,
};

export default function reducer(state = defaultState, action) {
  switch (action.type) {
    case '@@chmp:initialize':
      const {
        personalization: { member, location },
      } = action.payload;
      const urlParams = action.payload.personalization.urlParams || {};
      let countryCode = member.country || location.country;
      if (typeof countryCode !== 'string') countryCode = '';
      return {
        ...state,
        countryCode: member.country || location.country || '',
        previouslyConsented: member.consented || false,
        isRequiredNew: isRequired(
          { ...state, countryCode },
          c => !includes(['DE', 'AT'], c.alpha2)
        ),
        isRequiredExisting: isRequired({
          ...state,
          countryCode,
        }),
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
    case '@@chmp:consent:show_consent_required':
      return { ...state, showConsentRequired: action.value };
    case '@@chmp:consent:reset_state':
      return defaultState;
    default:
      return state;
  }
}

export function changeConsent(consented = false) {
  return { type: '@@chmp:consent:change_consent', consented };
}

export function changeCountry(countryCode = '') {
  return { type: '@@chmp:consent:change_country', countryCode };
}

export function changeVariant(variant = 'simple') {
  return { type: '@@chmp:consent:change_variant', variant };
}

export function resetState() {
  return { type: '@@chmp:consent:reset_state' };
}

export function toggleModal(value) {
  return { type: '@@chmp:consent:toggle_modal', modalOpen: value };
}

export function showConsentRequired(value) {
  return { type: '@@chmp:consent:show_consent_required', value };
}

export function dispatchFieldUpdate(name, value, dispatch = null) {
  if (!dispatch) return;
  if (name === 'country') return dispatch(changeCountry(value));
}

// Conditions:
// * selected country is in an affected country
// * user has not previously given consent
// * user has not selected to consent or not (`consented` is still null)
function isRequired(state, filter) {
  const { countryCode, consented, previouslyConsented } = state;
  const inAffectedCountry = includes(EEA_LIST, countryCode);
  return inAffectedCountry && !previouslyConsented && consented === null;
}
