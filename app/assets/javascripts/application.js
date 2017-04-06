// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require underscore
//= require backbone
//= require jquery-ui/widgets/sortable
//= require jquery.remotipart
//= require d3
//= require odometer
//= require moment

//= require bootstrap-sprockets
//= require selectize
//= require dropzone
//= require typeahead.jquery
//= require speakingurl
//= require summernote
//= require datatables
//= require datatables/dataTables.bootstrap
//= require i18n
//= require i18n/translations

//= require shared/pub_sub
//= require shared/show_errors
//= require campaigner-facing/syntax-highlighting
//= require campaigner-facing/dropzone_image_upload
//= require campaigner-facing/selectize_config
//= require campaigner-facing/search
//= require campaigner-facing/configure_wysiwyg
//= require campaigner-facing/form_preview

// ES6 files imported through Browserify
require('campaigner-facing/ajax');
require('campaigner-facing/page');
require('campaigner-facing/plugins_toggle');
require('campaigner-facing/sidebar');
require('campaigner-facing/tooltips');
require('campaigner-facing/collection_editor');
require('campaigner-facing/shares_editor');
require('campaigner-facing/actions_editor');
require('campaigner-facing/layout_picker');

window.PageEditBar =  require('campaigner-facing/page_edit_bar');
window.Analytics   =  require('campaigner-facing/analytics');
window.SurveyEditor       = require('campaigner-facing/survey_editor');
window.FormElementCreator = require('campaigner-facing/form_element_creator');
