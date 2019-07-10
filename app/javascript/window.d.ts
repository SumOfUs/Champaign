import * as EventEmitter from 'eventemitter3';
import * as I18n from 'i18n-js';
import { Store } from 'redux';
import { Fundraiser } from './plugins/fundraiser';
import { Petition } from './plugins/petition';
import Plugin, { IPluginConfig } from './plugins/plugin';
import { IAppState, IFormField } from './types';

declare global {
  // tslint:disable-next-line:interface-name
  interface Window {
    champaign: IChampaignGlobalObject;
    I18n: II18n & typeof I18n;
    store: Store<any>;
    ee: EventEmitter;
  }
}

interface IChampaignGlobalObject {
  page: IChampaignPage;
  personalization: {
    location: IChampaignLocation;
    member: IChampaignMember | {};
  };
  plugins: IChampaignPagePlugins;
  store?: Store<IAppState>;
}

interface IChampaignPagePlugins {
  actions_thermometer?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
  call_tool?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
  donations_thermometer?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
  email_pension?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
  email_tool?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
  email?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
  fundraiser?: IChampaignPluginData<IFundraiserPluginConfig, Fundraiser>;
  petition?: IChampaignPluginData<IPetitionPluginConfig, Petition>;
  survey?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
  text?: IChampaignPluginData<IPluginConfig, Plugin<any>>;
}

interface IChampaignPluginData<T, M> {
  [ref: string]: {
    config: T;
    instance?: M;
  };
}

interface IPetitionPluginConfig extends IPluginConfig {
  cta: string;
  description: string;
  form_id: number;
  outstanding_fields: string[];
  target: string;
  fields: IFormField[];
  ref: string;
}

interface IFundraiserPluginConfig extends IPluginConfig {
  description: string;
  donation_band_id: number | null | undefined;
  donation_bands: { [currency: string]: number[] };
  fields: IFormField[];
  form_id: number;
  outstanding_fields: string[];
  preselect_amount: boolean;
  recurring_default: string;
  title: string;
  ref: string;
}

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
  donor_status: string;
  registered: boolean;
  created_at: string;
  updated_at: string;
}

export interface IChampaignLocation {
  readonly country?: string;
  readonly country_code?: string;
  readonly country_name?: string;
  readonly currency?: string;
  readonly ip?: string;
  readonly latitude?: string;
  readonly longitude?: string;
}

export interface IChampaignPage {
  readonly action_count: number;
  readonly allow_duplicate_actions: boolean;
  readonly canonical_url: string;
  readonly created_at: string;
  readonly featured: boolean;
  readonly follow_up_page_id: number;
  readonly follow_up_plan: 'with_liquid' | 'with_page';
  readonly id: number;
  readonly language_id: number;
  readonly optimizely_status: 'optimizely_disabled' | 'optimizely_enabled';
  readonly primary_image_id: number;
  readonly publish_status: string;
  readonly slug: string;
  readonly status: string;
  readonly title: string;
  readonly updated_at: string;
  readonly ak_donation_resource_uri?: string;
  readonly ak_petition_resource_uri?: string;
  readonly campaign_id?: number;
  readonly follow_up_liquid_layout_id?: number;
}

interface II18n {
  lookup(key: string): string;
}
