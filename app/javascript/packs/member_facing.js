// import I18n from 'champaign-i18n';
require('whatwg-fetch');
require('../legacy/member-facing/registration');
require('../legacy/member-facing/track_shares');
// require('../plugins/recommend-pages');
require('../util/event_tracking');

import { mapValues, pick } from 'lodash';
import flatten from 'flat';
import URI from 'urijs';
import configureStore from '../state';
import redirectors from '../legacy/member-facing/redirectors';
import { FeaturesHelper } from '../state/features';
import DonationsThermometer from '../plugins/donations_thermometer';
import ProgressTracker from '../plugins/progress-tracker';
import asyncModules from '../async/';
import cookieConsent from '../modules/cookie-consent';
import * as legacy from '../legacy/member-facing/';

window.URI = URI;

const store = configureStore(window.champaign);

if (process.env.EXTERNAL_ASSETS_JS_PATH) {
  // $FlowIgnore
  require(process.env.EXTERNAL_ASSETS_JS_PATH);
}

window.champaign = window.champaign || {};

// Legacy components (Backbone)
legacy.setup(window.champaign);

// Async modules (module splitting)
asyncModules.setup(window.champaign);

Object.assign(window.champaign, {
  DonationsThermometer,
  ProgressTracker,
  redirectors,
  store,
  features: new FeaturesHelper(store),
});

document.addEventListener('DOMContentLoaded', function() {
  cookieConsent.init(window.champaign.personalization.location.country);
});
