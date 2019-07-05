import * as I18n from 'i18n-js';
import { Store } from 'redux';
import { Petition } from './plugins/petition';
import { IPluginConfig } from './plugins/plugin';
import { IAppState, IFormField } from './types';

declare global {
  // tslint:disable-next-line:interface-name
  interface Window {
    champaign: IChampaignGlobalObject;
    I18n: II18n & typeof I18n;
  }
}

interface IChampaignGlobalObject {
  page: IChampaignPage;
  personalization: {
    location: IChampaignLocation;
    member: IChampaignMember;
  };
  plugins: IChampaignPagePlugins;
  store?: Store<IAppState>;
}

interface IChampaignPagePlugins {
  petition?: IChampaignPluginData<IChampaignPetitionPluginData>;
}

interface IChampaignPluginData<T> {
  [ref: string]: T;
}

interface IChampaignPetitionPluginData {
  config: IPetitionPluginConfig;
  interface?: Petition;
}

interface IPetitionPluginConfig extends IPluginConfig {
  cta: string;
  description: string;
  ref: string;
  form_id: number;
  id: number;
  outstanding_fields: string[];
  target: string;
  fields: IFormField[];
}

type MemberDonorStatus = 'donor' | 'non_donor' | 'recurring_donor';
interface IChampaignMember {
  id: number;
  email: string;
  country: string;
  consented: boolean | null | undefined;
  consented_updated_at: string | null | undefined;
  name: string;
  first_name: string;
  last_name: string;
  full_name: string;
  welcome_name: string;
  postal: string;
  actionkit_user_id: string | null | undefined;
  donor_status: MemberDonorStatus;
  registered: boolean;
  created_at: string;
  updated_at: string;
}

export interface IChampaignLocation {
  country?: string;
  country_code?: string;
  country_name?: string;
  currency?: string;
  ip?: string;
  latitude?: string;
  longitude?: string;
}

export interface IChampaignPage {
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
}

interface II18n {
  lookup(key: string): string;
}
