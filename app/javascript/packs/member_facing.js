// @flow
import 'whatwg-fetch';
import '../shared/show_errors';
import '../member-facing/registration';
import '../member-facing/track_shares';
import '../recommend_pages/recommend_pages';
import '../util/event_tracking';

import URI from 'urijs';
import configureStore from '../state';
import Petition from '../member-facing/backbone/petition';
import PetitionAndScrollToConsent from '../member-facing/backbone/petition_and_scroll_to_consent';
import DoubleOptIn from '../member-facing/double_opt_in';
import Survey from '../member-facing/backbone/survey';
import ActionForm from '../member-facing/backbone/action_form';
import OverlayToggle from '../member-facing/backbone/overlay_toggle';
import Thermometer from '../member-facing/backbone/thermometer';
import Sidebar from '../member-facing/backbone/sidebar';
import Notification from '../member-facing/backbone/notification';
import SweetPlaceholder from '../member-facing/backbone/sweet_placeholder';
import CampaignerOverlay from '../member-facing/backbone/campaigner_overlay';
import redirectors from '../member-facing/redirectors';
import { formatMessage } from '../util/TranslationsLoader';

window.URI = URI;

if (process.env.EXTERNAL_ASSETS_JS_PATH) {
  // $FlowIgnore
  require(process.env.EXTERNAL_ASSETS_JS_PATH);
}

window.champaign = window.champaign || {};

const store = configureStore(window.champaign);

Object.assign(window.champaign, {
  Petition,
  PetitionAndScrollToConsent,
  Survey,
  ActionForm,
  OverlayToggle,
  Thermometer,
  Sidebar,
  Notification,
  SweetPlaceholder,
  CampaignerOverlay,
  DoubleOptIn,
  redirectors,
  store,
});
