// @flow

export type Page = {
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

const initialState: Page = {
  action_count: 0,
  allow_duplicate_actions: false,
  canonical_url: '',
  created_at: '',
  featured: false,
  follow_up_page_id: 0,
  follow_up_plan: 'with_liquid',
  id: 0,
  language_id: 1,
  optimizely_status: 'optimizely_disabled',
  primary_image_id: 0,
  publish_status: 'unpublished',
  slug: '',
  status: 'pending',
  title: '',
  updated_at: '',
};

export type PageAction = {
  type: 'initialize_page',
  payload: Page
};

export default function pageReducer(state: Page = initialState, action: PageAction) {
  if (action.type === 'initialize_page') {
      return action.payload;
  }
  return state;
}
