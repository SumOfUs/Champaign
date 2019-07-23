import { includes } from 'lodash';
import EEA_LIST from '../../shared/eea-list';
import { Member } from '../../state/member/';

export const isGDPR = (countryCode: string) => EEA_LIST.includes(countryCode);

export const isDoubleOptIn = (countryCode: string) => {
  return ['DE', 'AT'].includes(countryCode);
};

export const hasConsented = (member: Member) => {
  return member && member.consented != null;
};

export const isRequired = (countryCode: string, member: Member) => {
  if (!isGDPR(countryCode) || isDoubleOptIn(countryCode)) {
    return false;
  }
  return !hasConsented(member);
};

export default {
  hasConsented,
  isRequired,
  isGDPR,
  isDoubleOptIn,
};
