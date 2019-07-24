require('whatwg-fetch');
require('../legacy/member-facing/registration');
require('../legacy/member-facing/track_shares');
require('../util/event_tracking');

import { mapValues, pick } from 'lodash';
import flatten from 'flat';
import URI from 'urijs';
import configureStore from '../state';
import redirectors from '../legacy/member-facing/redirectors';
import { FeaturesHelper } from '../state/features';
import DonationsThermometer from '../plugins/donations_thermometer';
import ProgressTracker from '../plugins/progress-tracker';
import modules from '../modules/';
import cookieConsent from '../modules/cookie-consent';
import * as scrollToElement from '../modules/transition';
import * as legacy from '../legacy/member-facing/';

window.URI = URI;

const store = configureStore(window.champaign);

if (process.env.EXTERNAL_ASSETS_JS_PATH) {
  require(process.env.EXTERNAL_ASSETS_JS_PATH);
}

window.champaign = window.champaign || {};

// Legacy components (Backbone)
legacy.setup(window.champaign);

// Add modules to champaign.modules
window.champaign.modules = modules;

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
