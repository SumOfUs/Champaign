//= require sumofus

describe("fundraiser", function() {
  var suite = this;
  suite.timeout(10000);

  before(function() {
    suite.validatePath = /\/api\/pages\/[0-9]+\/actions\/validate/;
    window.onbeforeunload = function(){
      return 'Are you sure you want to leave?';
    };
  });

  afterEach(function() {
    suite.server.restore();
    suite.fundraiserBar.redirectTo.restore();
  });

  beforeEach(function() {
    MagicLamp.wish("pages/fundraiser");


    suite.server = sinon.fakeServer.create();
    suite.server.respondWith("GET", '/api/braintree/token',
                            [200, { "Content-Type": "application/json" },
                            '{ "token": "'+helpers.btClientToken+'" }' ]);

    suite.follow_up_url = "/pages/636/follow-up";
    suite.fundraiserBar = new window.FundraiserBar(suite.follow_up_url);
    sinon.stub(suite.fundraiserBar, 'redirectTo');
    suite.server.respond(); // respond to request for token
  });


  describe('loading and first panel', function(){

    it("shows only the first two panels of the donate panel", function() {
      expect(helpers.currentStepOf(3)).to.eq(1);
    });

    it('does not display the "next" button', function(){
      expect($('.fundraiser-bar__first-continue')).to.have.css('display', 'none');
    });

    it('autofills the custom amount with a dollar sign', function(){
      var $el = $('.fundraiser-bar__custom-field');
      expect($el).to.have.value('');
      $el.focus();
      expect($el).to.have.value('$');
    });

    it('reveals the "next" button when a custom amount is entered', function(){
      var $next = $('.fundraiser-bar__first-continue');
      var $input = $('.fundraiser-bar__custom-field');
      expect($next).to.have.css('display','none');
      $input.focus();
      expect($next).not.to.have.css('display','none');
      $input.blur();
      expect($next).have.css('display','none');
      $input.focus();
      $input.val('$25');
      $input.blur();
      expect($next).not.to.have.css('display','none');
    });

    it('moves to step 2 when amount button clicked', function(){
      $('.fundraiser-bar__amount-button').click();
      expect(helpers.currentStepOf(3)).to.eq(2);
    });

    it('moves to step 2 when next clicked with custom amount', function(){
      $('.fundraiser-bar__custom-field').val('$22');
      $('.fundraiser-bar__first-continue').click();
      expect(helpers.currentStepOf(3)).to.eq(2);
    });
 
    it('does not move to step 2 if custom amount has only dollar sign', function(){
      $('.fundraiser-bar__custom-field').val('$');
      $('.fundraiser-bar__first-continue').click();
      expect(helpers.currentStepOf(3)).to.eq(1);
    });

    it('displays the amount over step 1 after moving ahead', function(){
      $('.fundraiser-bar__custom-field').val('$22');
      $('.fundraiser-bar__first-continue').click();
      expect($('.fundraiser-bar__display-amount').text()).to.eq('$22');
    });
  });

  describe('second panel', function(){
    // most of the interaction on the form are on the form js, which is beyond the scope
    // of this test suite

    beforeEach(function(){
      $('.fundraiser-bar__custom-field').val('$22');
      $('.fundraiser-bar__first-continue').click();
    });

    it('returns to panel 1 if number 1 is clicked', function(){
      $('.fundraiser-bar__step-label[data-step="1"] .fundraiser-bar__step-number').click();
      expect(helpers.currentStepOf(3)).to.eq(1);
    });

    it('makes a request to validate the form', function(){
      $('.action-bar__submit-button').click();
      var request = helpers.last(suite.server.requests);
      expect(request.method).to.eq("POST");
      expect(request.url).to.match(suite.validatePath);
    });

    it('moves to panel 3 if validation passes', function(){
      $('.action-bar__submit-button').click();
      helpers.last(suite.server.requests).respond(200, { "Content-Type": "application/json" }, '{}');
      expect(helpers.currentStepOf(3)).to.eq(3);
    });

    it('stays on panel 2 if validation fails', function(){
      $('.action-bar__submit-button').click();
      helpers.last(suite.server.requests).respond(422, { "Content-Type": "application/json" }, '{ "errors": {} }');
      expect(helpers.currentStepOf(3)).to.eq(2);
    });
  });

  describe('third panel', function() {

    beforeEach(function(){
      suite.server.respondWith("POST", this.validatePath, ["200", {}, ""]);
      $('.fundraiser-bar__custom-field').val('$22');
      $('.fundraiser-bar__first-continue').click();
      $('.action-bar__submit-button').click();

      suite.server.respond();
      expect(helpers.currentStepOf(3)).to.eq(3);
    });

    it('disables the button when the form submits', function(){
      var $button = $('.fundraiser-bar__submit-button');
      expect($button).not.to.have.class('button--disabled');
      $button.click();
      expect($button).to.have.class('button--disabled');
    });

    xit('first makes a request to braintree', function(){
      // I don't think we can test this without some serious iframe hackery
    });

    it('sends the nonce to the server after receiving it from braintree', function(){
      suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
      request = helpers.last(suite.server.requests);
      expect(request.method).to.eq("POST");
      expect(request.url).to.eq("/api/braintree/transaction");

      expect(helpers.lastRequestBodyPairs(suite)).to.include.members(["payment_method_nonce="+helpers.btNonce, "amount=22"]);
    });

    it("sends 'recurring' as false by default", function(){
      suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
      expect(helpers.lastRequestBodyPairs(suite)).to.include.members(["recurring=false"]);
    });

    it("sends 'recurring' as true if it's checked", function(){
      $('input.fundraiser-bar__recurring').click();
      suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
      expect(helpers.lastRequestBodyPairs(suite)).to.include.members(["recurring=true"]);
    });

    it('loads the follow-up url after success from the server', function(){
      suite.server.respondWith('POST', "/api/braintree/transaction", [200, { "Content-Type": "application/json" }, '{ "success": "true" }' ]);
      suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
      suite.server.respond();
      expect(suite.fundraiserBar.redirectTo).to.have.been.calledWith(suite.follow_up_url);
    });

    xit('displays validation errors passed back from the server', function(){
      // it doesn't actually do this yet, spec is here as a reminder
    });
  });

});
