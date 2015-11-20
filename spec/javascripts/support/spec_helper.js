//= require jquery
//= require support/sinon
//= require support/chai
//= require chai-jquery
//= require magic_lamp

// require support/sinon-chai
// require_self

jQuery.fx.off = true;

MagicLamp.preload();

// var spies;
// var stubs;
// window.spyOn = function(object, method) {
//   var spy = sinon.spy(object, method);
//   spies.push(spy);
//   return spy;
// };

// window.stub = function(object, method, retVal) {
//   var stub = sinon.stub(object, method).returns(retVal);
//   stubs.push(stub);
//   return stub;
// };

// beforeEach(function() {
//   spies = [];
//   stubs = [];
// });

// afterEach(function() {
//   MagicLamp.clean();

//   _(spies).each(function(spy) {
//     spy.restore();
//   });

//   _(stubs).each(function(stub) {
//     stub.restore();
//   });
// });

window.expect = chai.expect;
