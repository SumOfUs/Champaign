import { IConsent } from './state/consent/consent';
import { IFormStore } from './state/forms';

export interface IAppState {
  readonly consent: IConsent;
  readonly member: Member;
  readonly forms: IFormStore;
  readonly page: any;
}

export interface IFormChoice {
  label: string;
  value: string;
  id: string;
}

export type FormFieldDisplayMode =
  | 'all_members'
  | 'recognized_members_only'
  | 'new_members_only';

export interface IFormField {
  id: string; // it comes from Champaign but we omit it when passing it down
  choices: IFormChoice[];
  data_type: string;
  default_value: boolean | string | number | undefined | null;
  display_mode: FormFieldDisplayMode;
  form_id: number;
  label: string;
  name: string;
  position: number;
  required: boolean;
  visible: boolean | undefined | null;
}

export type Member = {
  id: number;
  email: string;
  country?: string;
  consented: boolean;
  consentedUpdatedAt: boolean;
  name?: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  welcomeName?: string;
  postal?: string;
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  actionKitUserId?: string;
} | null;
