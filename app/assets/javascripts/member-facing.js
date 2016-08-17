//= require jquery
//= require jquery_ujs
//= require sticky
//= require underscore
//= require braintree-web
//= require backbone
//= require selectize

//= require i18n
//= require i18n/translations

//= require shared/pub_sub
//= require shared/show_errors

require("member-facing/scroll");
require("member-facing/ga_event_reporting");
window.sumofus = {};
window.sumofus.Petition      = require('member-facing/backbone/petition');
window.sumofus.ActionForm    = require('member-facing/backbone/action_form');
window.sumofus.Fundraiser    = require('member-facing/backbone/fundraiser');
window.sumofus.OverlayToggle = require('member-facing/backbone/overlay_toggle');
window.sumofus.Thermometer   = require('member-facing/backbone/thermometer');
window.sumofus.DesktopSticky = require('member-facing/backbone/desktop_sticky');
window.sumofus.Sidebar       = require('member-facing/backbone/sidebar');
window.sumofus.ActionCounter = require('member-facing/backbone/action_counter');
window.sumofus.SimpleCarousel = require('member-facing/backbone/simple_carousel');
window.sumofus.CampaignerOverlay     = require('member-facing/backbone/campaigner_overlay');
window.sumofus.BraintreeHostedFields = require('member-facing/backbone/braintree_hosted_fields');
