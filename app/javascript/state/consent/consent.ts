export interface IConsent {
  previouslyConsented: boolean;
  isRequiredNew: boolean;
  isRequiredExisting: boolean;
  consented: null | boolean;
  countryCode: string;
  variant: string;
  modalOpen: boolean;
  showConsentRequired: boolean;
}
