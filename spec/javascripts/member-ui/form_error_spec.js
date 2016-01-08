//= require sumofus

// this is a feature test of show_errors.js that ensures
// it performs in an end-user facing context
describe("Inline form errors", function() {
  var suite = this;
  suite.timeout(20000);

  before(function() {
    suite.actionPath = /\/api\/pages\/[0-9]+\/actions/;
  });

  beforeEach(function(){
    MagicLamp.wish("pages/petition");
    suite.server = sinon.fakeServer.create();
    suite.server.respondWith("GET", '/api/braintree/token',
                            [200, { "Content-Type": "application/json" },
                            '{ "token": "'+helpers.btClientToken+'" }' ]);
    suite.petitionBar = new window.sumofus.PetitionBar(); // binds the form events
  });

  afterEach(function(){
    suite.server.restore();
  });

  it('begins with no error messages', function(){
    expect($('.has-error').length).to.eq(0);
    expect($('.error-msg').length).to.eq(0);
  });

  describe('two errors', function(){

    beforeEach(function(){
      suite.server.respondWith("POST", suite.actionPath,
                               [422, { "Content-Type": "application/json" },
                              '{"errors":{"email":["is not a valid email address"], "name":["is required"]}}' ]);
      $('.petition-bar__submit-button').click();
      suite.server.respond();
    });

    it('adds "has-error" class to field and parent', function(){
      expect($('input[name="email"]')).to.have.class('has-error');
      expect($('input[name="email"]').parent()).to.have.class('has-error');
      expect($('input[name="name"]')).to.have.class('has-error');
      expect($('input[name="name"]').parent()).to.have.class('has-error');
    });

    it('adds an error message to all relevant fields', function(){
      var $msg = $('input[name="email"]').parent().find('.error-msg');
      expect($msg).to.have.length.above(0);
      expect($msg.text()).to.have.length.above(0);
      $msg = $('input[name="name"]').parent().find('.error-msg');
      expect($msg).to.have.length.above(0);
      expect($msg.text()).to.have.length.above(0);
    });
  });

  describe('one error', function(){

    beforeEach(function(){
      suite.server.respondWith("POST", suite.actionPath,
                               [422, { "Content-Type": "application/json" },
                              '{"errors":{"email":["is not a valid email address"]}}' ]);
      $('.petition-bar__submit-button').click();
      suite.server.respond();
    });

    it('can add an error message to just one field', function(){
      var $msg = $('input[name="email"]').parent().find('.error-msg');
      expect($msg).to.have.length.above(0);
      expect($msg.text()).to.have.length.above(0);
      $msg = $('input[name="name"]').parent().find('.error-msg');
      expect($msg).to.have.length(0);
      expect($msg.text()).to.have.length(0);
    });

    it('does not dismiss the error when field receives focus', function(){
      var $input = $('input[name="email"]');
      $input.focus();
      expect($input.parent()).to.have.class('has-error');
      expect($input.parent().find('.has-error')).to.have.length.above(0);
      expect($input.parent().find('.error-msg')).to.have.length.above(0);
    });

    it('dismisses the error when field value changes', function(){
      var $input = $('input[name="email"]');
      $input.change();
      expect($input.parent()).not.to.have.class('has-error');
      expect($input.parent().find('.has-error')).to.have.length(0);
      expect($input.parent().find('.error-msg')).to.have.length(0);
    });
  });

  describe('on second submission', function(){

    beforeEach(function(){
      suite.server.respondWith("POST", suite.actionPath,
                               [422, { "Content-Type": "application/json" },
                              '{"errors":{"email":["is not a valid email address"], "name":["is required"]}}' ]);
      $('.petition-bar__submit-button').click();
      suite.server.respond();
    });

    it('replaces existing error message if still has error', function(){
      expect($('input[name="email"].has-error').siblings('.error-msg').text()).to.eq('This field is not a valid email address');
      suite.server.respondWith("POST", suite.actionPath,
                               [422, { "Content-Type": "application/json" },
                              '{"errors":{"email":["is too hot to handle"], "name":["is required"]}}' ]);
      $('.petition-bar__submit-button').click();
      suite.server.respond();
      expect($('input[name="email"].has-error').siblings('.error-msg').text()).to.eq('This field is too hot to handle');
    });

    it('does not change anything if error is identical', function(){
      expect($('input[name="email"].has-error').siblings('.error-msg')).to.have.length(1);
      expect($('input[name="email"].has-error').siblings('.error-msg').text()).to.eq('This field is not a valid email address');
      $('.petition-bar__submit-button').click();
      suite.server.respond();
      expect($('input[name="email"].has-error').siblings('.error-msg')).to.have.length(1);
      expect($('input[name="email"].has-error').siblings('.error-msg').text()).to.eq('This field is not a valid email address');
    });

    it('clears the error on success', function(){
      expect($('input[name="email"].has-error').siblings('.error-msg')).to.have.length(1);
      suite.server.respondWith("POST", suite.actionPath, [200, { "Content-Type": "application/json" }, '{}' ]);
      $('.petition-bar__submit-button').click();
      suite.server.respond();
      expect($('input[name="email"]').siblings('.error-msg')).to.have.length(0);
      expect($('input[name="email"]')).not.to.have.class('has-error');
    });
  });

});


