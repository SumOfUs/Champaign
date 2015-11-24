//= require sumofus

describe("fundraiser", function() {

  before(function() {
    this.server = sinon.fakeServer.create();
    this.server.respondWith("GET", '/api/braintree/token',
      [200, { "Content-Type": "application/json" },
             '{ "token": '+helpers.btClientToken+' }' ]);
  });

  after(function() {
    this.server.restore();
  });

  beforeEach(function() {
    MagicLamp.wish("pages/fundraiser");
    var myFundraiserBar = new window.FundraiserBar("/pages/636/follow-up");
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

    before(function(){
      this.validatePath = /\/api\/pages\/[0-9]+\/actions\/validate/;
      this.xhr = sinon.useFakeXMLHttpRequest();
      self = this;
      self.requests = [];
      this.xhr.onCreate = function(xhr) {
        self.requests.push(xhr);
      };
    });

    beforeEach(function(){
      $('.fundraiser-bar__custom-field').val('$22');
      $('.fundraiser-bar__first-continue').click();
      this.requests = [];
    });

    it('returns to panel 1 if number 1 is clicked', function(){
      $('.fundraiser-bar__step-label[data-step="1"] .fundraiser-bar__step-number').click();
      expect(helpers.currentStepOf(3)).to.eq(1);
    });

    it('makes a request to validate the form', function(){
      $('.action-bar__submit-button').click();
      expect(this.requests[0].method).to.eq("POST");
      expect(this.requests[0].url).to.match(this.validatePath);
    });

    it('moves to panel 3 if validation passes', function(){
      $('.action-bar__submit-button').click();
      this.requests[0].respond(200, { "Content-Type": "application/json" }, '{}');
      expect(helpers.currentStepOf(3)).to.eq(3);
    });

    it('stays on panel 2 if validation fails', function(){
      $('.action-bar__submit-button').click();
      this.requests[0].respond(422, { "Content-Type": "application/json" }, '{ "errors": {} }');
      expect(helpers.currentStepOf(3)).to.eq(2);
    });
  });

});
