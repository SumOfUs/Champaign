import 'whatwg-fetch';
import '../shared/show_errors';
import '../member-facing/registration';
import '../member-facing/track_shares';
import '../recommend_pages/recommend_pages';
import '../util/event_tracking';

import { mapValues, pick } from 'lodash';
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
import { FeaturesHelper } from '../state/features';
import DonationsThermometer from '../plugins/donations-thermometer';
import ProgressTracker from '../plugins/progress-tracker';

window.URI = URI;

if (process.env.EXTERNAL_ASSETS_JS_PATH) {
  // $FlowIgnore
  require(process.env.EXTERNAL_ASSETS_JS_PATH);
}

window.champaign = window.champaign || {};

const store = configureStore(window.champaign);

Object.assign(window.champaign, {
  ActionForm,
  CampaignerOverlay,
  DonationsThermometer,
  DoubleOptIn,
  Notification,
  OverlayToggle,
  Petition,
  PetitionAndScrollToConsent,
  ProgressTracker,
  Sidebar,
  Survey,
  SweetPlaceholder,
  Thermometer,
  redirectors,
  store,
  features: new FeaturesHelper(store),
});

import flatten from 'flat';

I18n.flatTranslations = mapValues(I18n.translations, (value, key) =>
  flatten(
    pick(value, [
      'double_opt_in',
      'footer',
      'page',
      'basics',
      'branding',
      'recommend_pages',
      'email_pension',
      'email_tool',
      'fundraiser',
      'petition',
      'form',
      'thermometer',
      'call_tool',
      'share',
      'errors',
      'validation',
      'time',
      'reset_passwords',
      'survey',
      'reset_password_mailer',
      'facebook_share',
      'member_registration',
      'confirmation_mailer',
      'consent',
      'cookie_consent',
    ])
  )
);
