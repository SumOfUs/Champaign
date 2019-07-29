import { IConsent } from './state/consent/consent';
import { IFormStore } from './state/forms';
import { IFundraiserState } from './state/fundraiser';
import { Member } from './state/member';
export interface IAppState {
  readonly consent: IConsent;
  readonly forms: IFormStore;
  readonly fundraiser: IFundraiserState;
  readonly member: Member;
  readonly page: any;
  readonly donationsThermometer: any;
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
