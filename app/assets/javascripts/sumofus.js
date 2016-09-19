//= require jquery
//= require jquery_ujs
//= require pub_sub
//= require sticky
//= require lodash
//= require braintree-web
//= require backbone

//= require i18n
//= require i18n/translations

//= require show_errors
//= require selectize
//= require_directory ./plugins

require("sumofus/scroll");
require("sumofus/ga_event_reporting");
window.sumofus = {};
window.sumofus.Petition      = require('sumofus/backbone/petition');
window.sumofus.ActionForm    = require('sumofus/backbone/action_form');
window.sumofus.Fundraiser    = require('sumofus/backbone/fundraiser');
window.sumofus.OverlayToggle = require('sumofus/backbone/overlay_toggle');
window.sumofus.Thermometer   = require('sumofus/backbone/thermometer');
window.sumofus.DesktopSticky = require('sumofus/backbone/desktop_sticky');
window.sumofus.Sidebar       = require('sumofus/backbone/sidebar');
window.sumofus.ActionCounter = require('sumofus/backbone/action_counter');
window.sumofus.SimpleCarousel = require('sumofus/backbone/simple_carousel');
window.sumofus.CampaignerOverlay     = require('sumofus/backbone/campaigner_overlay');
window.sumofus.BraintreeHostedFields = require('sumofus/backbone/braintree_hosted_fields');
