// @flow

const initialState: ChampaignPage = {
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
  type: '@champaign:page:init',
  payload: ChampaignPage,
};

export default function pageReducer(
  state: ChampaignPage = initialState,
  action: PageAction
) {
  if (action.type === '@champaign:page:init') {
    return action.payload;
  }
  return state;
}
