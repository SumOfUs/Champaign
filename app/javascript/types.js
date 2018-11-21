/* eslint-disable */
// @flow
import type { Store } from 'redux';
import type { AppState } from './state/reducers';

export type ChampaignMember =
  | {
      id: number,
      email: string,
      country: string,
      consented: boolean | null,
      consented_updated_at: string | null,
      name: string,
      first_name: string,
      last_name: string,
      full_name: string,
      welcome_name: string,
      postal: string,
      actionkit_user_id: ?string,
      donor_status: 'donor' | 'non_donor' | 'recurring_donor',
      registered: boolean,
      created_at: string,
      updated_at: string,
    }
  | {};

export type ChampaignLocation = {
  country?: string,
  country_code?: string,
  country_name?: string,
  currency?: string,
  ip?: string,
  latitude?: string,
  longitude?: string,
};

export type ChampaignPage = {
  action_count: number,
  allow_duplicate_actions: boolean,
  canonical_url: string,
  created_at: string,
  featured: boolean,
  follow_up_page_id: number,
  follow_up_plan: 'with_liquid' | 'with_page',
  id: number,
  language_id: number,
  optimizely_status: 'optimizely_disabled' | 'optimizely_enabled',
  primary_image_id: number,
  publish_status: string,
  slug: string,
  status: string,
  title: string,
  updated_at: string,
  ak_donation_resource_uri?: string,
  ak_petition_resource_uri?: string,
  campaign_id?: number,
  follow_up_liquid_layout_id?: number,
};

export type ChampaignPersonalizationData = {
  locale: string,
  location: ChampaignLocation,
  member: ChampaignMember,
  paymentMethods: any[],
  urlParams: { [key: string]: string },
};

export type ChampaignGlobalObject = {
  personalization: ChampaignPersonalizationData,
  page: ChampaignPage,
  store?: Store<AppState, *>,
};

export type FBStandardEvent =
  | 'ViewContent'
  | 'Search'
  | 'AddToCart'
  | 'AddToWishlist'
  | 'InitiateCheckout'
  | 'AddPaymentInfo'
  | 'Purchase'
  | 'Lead'
  | 'CompleteRegistration';

export type FBEventParams = {
  value?: any,
  currency?: any,
  content_name?: any,
  content_category?: any,
  content_type?: any,
  content_ids?: any[],
  num_items?: any,
};
