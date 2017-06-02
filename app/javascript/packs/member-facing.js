import '../shared/pub_sub';
import '../shared/show_errors';
import '../member-facing/registration';

let initializeApp = () => {
  window.URI = require('urijs');
  window.sumofus = window.sumofus || {}; // for legacy templates that reference window.sumofus
  window.champaign = window.champaign || window.sumofus || {};
  window.champaign.Petition = require('../member-facing/backbone/petition');
  window.champaign.Survey = require('../member-facing/backbone/survey');
  window.champaign.ActionForm = require('../member-facing/backbone/action_form');
  window.champaign.OverlayToggle = require('../member-facing/backbone/overlay_toggle');
  window.champaign.Thermometer = require('../member-facing/backbone/thermometer');
  window.champaign.Sidebar = require('../member-facing/backbone/sidebar');
  window.champaign.Notification = require('../member-facing/backbone/notification');
  window.champaign.SweetPlaceholder = require('../member-facing/backbone/sweet_placeholder');
  window.champaign.CampaignerOverlay = require('../member-facing/backbone/campaigner_overlay');
  window.champaign.BraintreeHostedFields = require('../member-facing/backbone/braintree_hosted_fields');
  window.champaign.redirectors = require('../member-facing/redirectors');
};

if (window.ChampaignSettings && window.ChampaignSettings.airbrake) {
  const airbrakeJs = require('airbrake-js');
  const airbrake = new airbrakeJs(window.ChampaignSettings.airbrake);
  initializeApp = airbrake.wrap(initializeApp);
}
require('../member-facing/track_shares');

initializeApp();
