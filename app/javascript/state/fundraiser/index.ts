import { IFormField } from '../../types';

export const RECURRING_DEFAULTS = ['one_off', 'recurring', 'only_recurring'];
export interface IFundraiserState {
  currency: string;
  currentPaymentType: string;
  currentStep: number;
  showDirectDebit: boolean;
  directDebitOnly: boolean;
  disableSavedPayments: boolean;
  donationAmount: undefined;
  donationBands: { [currency: string]: number[] };
  fields: IFormField[];
  form: { [fieldName: string]: string };
  formId: string;
  formValues: { [fieldName: string]: string };
  freestanding: boolean;
  oneClick: boolean;
  outstandingFields: string[];
  paymentMethods: any[];
  paymentTypes: string[];
  preselectAmount: boolean;
  recurring: boolean;
  recurringDefault: string;
  storeInVault: boolean;
  submitting: boolean;
  oneClickError: boolean;
  title: string;
}
