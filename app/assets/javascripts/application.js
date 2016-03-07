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
//= require pub_sub
//= require jquery-ui/sortable
//= require jquery.remotipart
//= require d3
//= require odometer
//= require moment

//= require bootstrap-sprockets
//= require selectize
//= require dropzone
//= require syntax-highlighting
//= require typeahead.jquery
//= require speakingurl
//= require summernote
//= require datatables
//= require datatables/dataTables.bootstrap

//= require i18n
//= require i18n/translations
//= require show_errors
//= require dropzone_image_upload
//= require selectize_config
//= require search
//= require configure_wysiwyg
//= require_tree ./plugins/admin

require('ajax')
require('page');
require("plugins_toggle");
require("sidebar");
require("tooltips");
require("collection_editor");
require('shares_editor');
require('layout_picker');

window.PageEditBar =  require("page_edit_bar");
window.Analytics   =  require('analytics');
