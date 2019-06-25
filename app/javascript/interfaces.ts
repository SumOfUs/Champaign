import { Store } from 'redux';
import { AppState } from './state';

export type ChampaignGlobalObject = {
  personalization: ChampaignPersonalizationData;
  plugins: {
    [name: string]: {
      [ref: string]: {
        config: PluginSettings;
        instance?: any;
      };
    };
  };
  page: ChampaignPage;
  store?: Store<AppState>;
};

namespace ChampaignForm {
  export type FormId = string;

  export type Choice = {
    label: string;
    value: string;
    id: string;
  };

  export type FormFieldDisplayMode =
    | 'all_members'
    | 'recognized_members_only'
    | 'new_members_only';

  export type FormField = {
    id: FormId; // it comes from Champaign but we omit it here
    choices: Choice[];
    data_type: string;
    default_value: string | void;
    display_mode: FormFieldDisplayMode;
    form_id: number;
    label: string;
    name: string;
    position: number;
    required: boolean;
    visible: boolean | void;
  };
}

export type PluginSettings = {
  active: boolean;
  cta: string;
  description: string;
  fields: ChampaignForm.FormField[];
  form_id: ChampaignForm.FormId;
  id: number;
  outstanding_fields: string[];
  page_id: number;
  target: string;
};
export type ChampaignMember =
  | {
      id: number;
      email: string;
      country: string;
      consented: boolean | null;
      consented_updated_at: string | null;
      name: string;
      first_name: string;
      last_name: string;
      full_name: string;
      welcome_name: string;
      postal: string;
      actionkit_user_id: string | null;
      donor_status: 'donor' | 'non_donor' | 'recurring_donor';
      registered: boolean;
      created_at: string;
      updated_at: string;
    }
  | {};

export type ChampaignLocation = {
  country?: string;
  country_code?: string;
  country_name?: string;
  currency?: string;
  ip?: string;
  latitude?: string;
  longitude?: string;
};

export type ChampaignPage = {
  action_count: number;
  allow_duplicate_actions: boolean;
  canonical_url: string;
  created_at: string;
  featured: boolean;
  follow_up_page_id: number;
  follow_up_plan: 'with_liquid' | 'with_page';
  id: number;
  language_id: number;
  optimizely_status: 'optimizely_disabled' | 'optimizely_enabled';
  primary_image_id: number;
  publish_status: string;
  slug: string;
  status: string;
  title: string;
  updated_at: string;
  ak_donation_resource_uri?: string;
  ak_petition_resource_uri?: string;
  campaign_id?: number;
  follow_up_liquid_layout_id?: number;
};

type DonationsThermometer =
  | {}
  | {
      active: boolean;
      goals: { [currency: string]: number };
      offset: number;
      remaining_amounts: { [currency: string]: number };
      title: string;
      total_donations: { [currency: string]: number };
    };
export type ChampaignPersonalizationData = {
  locale: string;
  location: ChampaignLocation;
  member: ChampaignMember;
  paymentMethods: any[];
  urlParams: { [key: string]: string };
  donationsThermometer: DonationsThermometer;
};
