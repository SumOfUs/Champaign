import 'babel-polyfill';
import '../shared/pub_sub';
import '../shared/show_errors';
import '../member-facing/registration';
import '../member-facing/track_shares';
import 'whatwg-fetch';

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
import ConsentFeature from '../consent/index';

window.URI = URI;

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
    ConsentFeature,
    store: configureStore({}),
  });
};

initializeApp();
