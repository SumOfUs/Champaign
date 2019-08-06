import { FeaturesHelper } from '../state/features';
import * as scrollToElement from '../modules/transition';
import configureStore from '../state';
import cookieConsent from '../modules/cookie-consent';
import DonationsThermometer from '../plugins/donations_thermometer';
import modules from '../modules/';
import ProgressTracker from '../plugins/progress-tracker';
import redirectors from '../legacy/member-facing/redirectors';
import URI from 'urijs';

require('whatwg-fetch'); // TODO use fetch-ponyfill
require('../legacy/member-facing/');
require('../util/event_tracking');

const store = configureStore(window.champaign);

window.URI = URI;
window.champaign.store = store;
window.champaign.modules = modules;
window.champaign.DonationsThermometer = DonationsThermometer;
window.champaign.features = new FeaturesHelper(store);
window.champaign.ProgressTracker = ProgressTracker;
window.champaign.redirectors = redirectors;

document.addEventListener('DOMContentLoaded', function() {
  cookieConsent.init(window.champaign.personalization.location.country);
});
