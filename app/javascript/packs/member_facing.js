import $ from 'jquery';
import 'babel-polyfill';
import 'whatwg-fetch';
import '../shared/pub_sub';
import '../shared/show_errors';
import '../member-facing/registration';
import '../member-facing/track_shares';

import URI from 'urijs';
import configureStore from '../state';
import Petition from '../member-facing/backbone/petition';
import Fundraiser from '../member-facing/backbone/fundraiser';
import Survey from '../member-facing/backbone/survey';
import ActionForm from '../member-facing/backbone/action_form';
import OverlayToggle from '../member-facing/backbone/overlay_toggle';
import Thermometer from '../member-facing/backbone/thermometer';
import Sidebar from '../member-facing/backbone/sidebar';
import Notification from '../member-facing/backbone/notification';
import SweetPlaceholder from '../member-facing/backbone/sweet_placeholder';
import CampaignerOverlay from '../member-facing/backbone/campaigner_overlay';
import BraintreeHostedFields from '../member-facing/backbone/braintree_hosted_fields';
import redirectors from '../member-facing/redirectors';

window.URI = URI;

// TODO: Move this out? External js needs to be compiled (webpack or sprockets)
// so it's not something we can import dynamically in the browser, unless we have
// a compiled bundle to reference.
if (process.env.EXTERNAL_ASSETS_JS_PATH) {
  require(process.env.EXTERNAL_ASSETS_JS_PATH);
}

const initializeApp = () => {
  window.sumofus = window.sumofus || {}; // for legacy templates that reference window.sumofus
  window.champaign = window.champaign || window.sumofus || {};
  Object.assign(window.champaign, {
    Petition,
    Fundraiser,
    Survey,
    ActionForm,
    OverlayToggle,
    Thermometer,
    Sidebar,
    Notification,
    SweetPlaceholder,
    CampaignerOverlay,
    BraintreeHostedFields,
    redirectors,
  });
};

initializeApp();

// TODO: Improve how we initialize the store (use localStorage when possible)
const store = (window.champaign.store = configureStore({}));

$(() => {
  const { page, personalization, config } = window.champaign;

  store.dispatch({
    type: '@champaign:config:init',
    payload: config,
    skip_log: true
  });
})
