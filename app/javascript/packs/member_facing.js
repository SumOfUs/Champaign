import I18n from 'champaign-i18n';
import 'whatwg-fetch';
import '../shared/show_errors';
import '../member-facing/registration';
import '../member-facing/track_shares';
import '../recommend_pages/recommend_pages';
import '../util/event_tracking';

import { mapValues, pick } from 'lodash';
import flatten from 'flat';
import URI from 'urijs';
import configureStore from '../state';
import redirectors from '../member-facing/redirectors';
import { FeaturesHelper } from '../state/features';
import DonationsThermometer from '../plugins/donations-thermometer';
import ProgressTracker from '../plugins/progress-tracker';
import asyncModules from '../async/';
import * as legacy from '../member-facing/';
window.URI = URI;

if (process.env.EXTERNAL_ASSETS_JS_PATH) {
  // $FlowIgnore
  require(process.env.EXTERNAL_ASSETS_JS_PATH);
}

window.champaign = window.champaign || {};

// Legacy components (Backbone)
legacy.setup(window.champaign);

// Async modules (module splitting)
asyncModules.setup(window.champaign);

const store = configureStore(window.champaign);

Object.assign(window.champaign, {
  DonationsThermometer,
  ProgressTracker,
  redirectors,
  store,
  features: new FeaturesHelper(store),
});

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

// Styles (hack)
// The following isn't loading when dynamically importing a module.
// so I'm adding it directly to the root of the import
import '../components/EmailEditor/EmailEditor.scss';
