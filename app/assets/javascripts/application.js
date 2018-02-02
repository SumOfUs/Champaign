// GLOBAL DEPENDENCIES FOR CAMPAIGNER FACING PAGES
// Most of these are required as globals and a few of them are actually gems that
// don't seem to work very well with npm-based build pipelines. For example, `dropzone`
// doesn't seem to have the compiled versions and attempts to require `./lib/dropzone.js`
// but the npm package only has `src/dropzone.coffee`.

//= require bootstrap-sprockets
//= require typeahead.jquery
//= require datatables
//= require datatables/dataTables.bootstrap
//= require dropzone
//= require odometer
// require speakingurl
//= require codemirror
//= require codemirror/modes/htmlmixed
//= require codemirror/modes/javascript
//= require codemirror/modes/xml
//= require codemirror/modes/css
//= require summernote
