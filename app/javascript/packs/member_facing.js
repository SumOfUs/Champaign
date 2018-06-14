import 'babel-polyfill';
import 'whatwg-fetch';
import 'cookieconsent';
import '../shared/pub_sub';
import '../shared/show_errors';
import '../member-facing/registration';
import '../member-facing/track_shares';
import '../util/intl-locale-data';

require('lodash');
require('backbone');
import URI from 'urijs';
import configureStore from '../state';
import Petition from '../member-facing/backbone/petition';
import PetitionAndScrollToConsent from '../member-facing/backbone/petition_and_scroll_to_consent';
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
import initializeCookieConsent from '../member-facing/cookieConsent';

window.URI = URI;

if (process.env.EXTERNAL_ASSETS_JS_PATH) {
  require(process.env.EXTERNAL_ASSETS_JS_PATH);
}

const initializeApp = () => {
  window.sumofus = window.sumofus || {}; // for legacy templates that reference window.sumofus
  window.champaign = window.champaign || window.sumofus || {};
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
    redirectors,
    store,
  });
};

$(document).ready(() => initializeCookieConsent());

initializeApp();
