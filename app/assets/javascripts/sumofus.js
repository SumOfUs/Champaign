//= require jquery
//= require jquery_ujs
//= require pub_sub
//= require sticky
//= require underscore
//= require braintree-web
//= require backbone

//= require i18n
//= require i18n/translations

//= require show_errors
//= require selectize
//= require_directory ./plugins

require("sumofus/scroll");
window.sumofus = {};
window.sumofus.PetitionBar   = require('sumofus/backbone/petition_bar');
window.sumofus.ActionForm    = require('sumofus/backbone/action_form');
window.sumofus.FundraiserBar = require('sumofus/backbone/fundraiser_bar');
window.sumofus.OverlayToggle = require('sumofus/backbone/overlay_toggle');
window.sumofus.Thermometer   = require('sumofus/backbone/thermometer');
window.sumofus.DesktopSticky = require('sumofus/backbone/desktop_sticky');
window.sumofus.Sidebar       = require('sumofus/backbone/sidebar');
window.sumofus.CampaignerOverlay = require('sumofus/backbone/campaigner_overlay');
