//= require jquery
//= require support/sinon
//= require support/chai
//= require chai-jquery
//= require magic_lamp
//= require support/sinon-chai
//= require support/helper_functions

// PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
// Use this polyfill to avoid the confusion.
//= require support/phantomjs-shims

// You can require your own javascript files here. By default this will include everything in application, however you
// may get better load performance if you require the specific files that are being used in the spec that tests them.
// require application
//
// Deferring execution
// If you're using CommonJS, RequireJS or some other asynchronous library you can defer execution. Call
// Teaspoon.execute() after everything has been loaded. Simple example of a timeout:
//
// Teaspoon.defer = true
// setTimeout(Teaspoon.execute, 1000)
//
// Matching files
// By default Teaspoon will look for files that match _spec.{js,js.coffee,.coffee}. Add a filename_spec.js file in your
// spec path and it'll be included in the default suite automatically. If you want to customize suites, check out the
// configuration in teaspoon_env.rb


////// Requiring tests
//= require member-ui/petition_spec
//= require member-ui/form_error_spec
//= require member-ui/fundraiser_spec


jQuery.fx.off = true;
window.expect = chai.expect;

