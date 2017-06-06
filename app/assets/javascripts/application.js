// GLOBAL DEPENDENCIES FOR CAMPAIGNER FACING PAGES
// Most of these are required as globals and a few of them are actually gems that
// don't seem to work very well with npm-based build pipelines. For example, `dropzone`
// doesn't seem to have the compiled versions and attempts to require `./lib/dropzone.js`
// but the npm package only has `src/dropzone.coffee`.

//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require jquery.remotipart
//= require bootstrap-sprockets
//= require typeahead.jquery
//= require datatables
//= require datatables/dataTables.bootstrap
//= require i18n
//= require i18n/translations
//= require dropzone
//= require d3
//= require odometer
//= require moment
//= require selectize
//= require speakingurl
//= require summernote
