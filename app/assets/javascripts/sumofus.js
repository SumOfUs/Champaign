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
window.sumofus.PetitionBar = require('sumofus/backbone/petition_bar');
window.sumofus.FundraiserBar = require('sumofus/backbone/fundraiser_bar');
window.sumofus.CampaignerOverlay = require('sumofus/backbone/campaigner_overlay');
