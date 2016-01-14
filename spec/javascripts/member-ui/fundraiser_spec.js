//= require sumofus

describe("Fundraiser", function() {
  var suite = this;
  suite.timeout(20000);

  before(function() {
    suite.validatePath = /\/api\/pages\/[0-9]+\/actions\/validate/;
    window.onbeforeunload = function(){
      // the javascript has redirects, this prevents them firing if you view the tests in browser
      return 'Are you sure you want to leave?';
    };
  });

  beforeEach(function(){
    MagicLamp.wish("pages/fundraiser");
    suite.server = sinon.fakeServer.create();
    suite.server.respondWith("GET", '/api/braintree/token',
                            [200, { "Content-Type": "application/json" },
                            '{ "token": "'+helpers.btClientToken+'" }' ]);
    suite.server.respond();
  });

  afterEach(function(){
    suite.server.restore();
  });

  describe('instantiation', function(){

    it('sets the default currency if currency passed', function(){
      suite.fundraiserBar = new window.sumofus.FundraiserBar({ currency: 'GBP'});
      expect($('.fundraiser-bar__currency-selector').val()).to.equal('GBP');
    });

    it('displays the values from the correct passed currency band', function(){
      var donationBands = {
        EUR: [1, 2, 3, 4, 5],
        USD: [6, 7, 8, 9, 10],
        GBP: [7, 14, 21, 28, 35]
      };
      suite.fundraiserBar = new window.sumofus.FundraiserBar({ currency: 'EUR', donationBands: donationBands});
      var displayedAmounts = $('.fundraiser-bar__amount-button').map(function(ii, a){ return $(a).data('amount'); }).toArray();
      expect(displayedAmounts).to.include.members(donationBands['EUR']);
    });

    describe('outstanding fields is empty', function(){

      describe('member is not passed', function(){

        it('hides the second step if there are no fields', function(){
          $('.fundraiser-bar .petition-bar__field-container').remove();
          expect($('.fundraiser-bar .petition-bar__field-container').length).to.equal(0);
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: [] });
          expect($('.fundraiser-bar__step-label[data-step="2"]')).to.have.css('visibility', 'hidden');
          $('.fundraiser-bar__amount-button').first().click();
          expect(helpers.currentStepOf(3)).to.eq(3);
        });

        describe('amount is not passed', function(){

          beforeEach(function(){
            suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: [] });
          });

          it('does not prefill values', function(){
            var vals = $('.petition-bar__field-container').map(function(ii, el){ return $(el).val() }).toArray();
            expect(vals).to.eql([""]);
          });

          it('does not hide the second step if there are fields', function(){
            expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
          });

          it('starts on the first step', function(){
            expect(helpers.currentStepOf(3)).to.eq(1);
          });
        });

      });

      it('ignores extraneous member values', function(){
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: [], member: {email: 'neal@test.com', oogle: 'boogle'} });
        expect($('input[name="email"]').val()).to.eql('neal@test.com');
      });

      it('does not display the clearer when form has no fields', function(){
        $('.fundraiser-bar .petition-bar__field-container').remove();
        expect($('.fundraiser-bar .petition-bar__field-container').length).to.equal(0);
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: [], member: {email: 'neal@test.com'} });
        expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
        expect($('.fundraiser-bar__welcome-text')).to.have.class('hidden-irrelevant');
      });

      describe('member is passed', function(){

        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: [], member: {email: 'neal@test.com'} });
        });

        it('displays the clearer when form has fields', function(){
          expect($('.fundraiser-bar .petition-bar__field-container').length).to.be.at.least(1);
          expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
          expect($('.fundraiser-bar__welcome-text')).not.to.have.class('hidden-irrelevant');
        });

        it('prefills with values of member', function(){
          expect($('input[name="email"]').val()).to.eql('neal@test.com');
        });

        it('hides the form fields', function(){
            var classed = $('.petition-bar__field-container').map(function(ii, el){
              return $(el).hasClass('form__group--prefilled');
            }).toArray();
            expect(classed).to.eql([true]);
        });

        it('displays the second step when user requests', function(){
          $('.fundraiser-bar__amount-button').first().click();
          expect(helpers.currentStepOf(3)).to.eq(3);
          $('.fundraiser-bar__clear-form').click();
          expect(helpers.currentStepOf(3)).to.eq(2);
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });

        it('clears prefilled fields when second step displayed', function(){
          var input = $('.fundraiser-bar__step-panel[data-step="2"] input').last();
          input.parents('.form__group').addClass('form__group--prefilled');
          expect(input.val()).to.equal('neal@test.com');
          $('.fundraiser-bar__amount-button').first().click();
          $('.fundraiser-bar__clear-form').click();
          expect(input.val()).to.equal('');
        });
      });

      describe('amount is greater than zero', function(){

        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: [], amount: 11, member: {} });
        });

        it('skips to the third step', function(){
          expect(helpers.currentStepOf(3)).to.eq(3);
        });

        it('displays the correct amount', function(){
          expect($('.fundraiser-bar__display-amount').text()).to.eq('$11');
        });

        it('hides the second step', function(){
          expect($('.fundraiser-bar__step-label[data-step="2"]')).to.have.css('visibility', 'hidden');
        });

        it('displays the second step when user requests', function(){
          $('.fundraiser-bar__clear-form').click();
          expect(helpers.currentStepOf(3)).to.eq(2);
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });

        it('clears prefilled fields when second step displayed', function(){
          var input = $('.fundraiser-bar__step-panel[data-step="2"] input').last();
          input.parents('.form__group').addClass('form__group--prefilled');
          input.val('cheerio!');
          expect(input.val()).to.equal('cheerio!');
          $('.fundraiser-bar__amount-button').first().click();
          $('.fundraiser-bar__clear-form').click();
          expect(input.val()).to.equal('');
        });
      });
    });

    describe('outstanding fields is not passed', function(){

      describe('amount is not passed', function(){

        describe('member is not passed', function(){

          beforeEach(function(){
            suite.fundraiserBar = new window.sumofus.FundraiserBar({});
          });

          it('starts on the first step', function(){
            expect(helpers.currentStepOf(3)).to.eq(1);
          });

          it('displays the second step', function(){
            expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
          });

          it('does not display the clearer', function(){
            expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
            expect($('.fundraiser-bar__welcome-text')).to.have.class('hidden-irrelevant');
          });

          it('does not prefill', function(){
            expect($('input[name="email"]').val()).to.eql('');
          });

          it('does not hide the form fields', function(){
            var classed = $('.petition-bar__field-container').map(function(ii, el){
              return $(el).hasClass('form__group--prefilled');
            }).toArray();
            expect(classed).to.eql([false]);
          });
        });

        describe('member is passed', function(){

          beforeEach(function(){
            suite.fundraiserBar = new window.sumofus.FundraiserBar({member: {email: 'neal@test.com'}});
          });

          it('starts on the first step', function(){
            expect(helpers.currentStepOf(3)).to.eq(1);
          });

          it('displays the second step', function(){
            expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
          });

          it('does not display the clearer', function(){
            expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
            expect($('.fundraiser-bar__welcome-text')).to.have.class('hidden-irrelevant');
          });

          it('prefills with values of member', function(){
            expect($('input[name="email"]').val()).to.eql('neal@test.com');
          });

          it('does not hide the form fields', function(){
            var classed = $('.petition-bar__field-container').map(function(ii, el){
              return $(el).hasClass('form__group--prefilled');
            }).toArray();
            expect(classed).to.eql([false]);
          });
        });
      });

      describe('amount is greater than zero ', function(){

        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({amount: 17});
        });

        it('skips to the second step', function(){
          expect(helpers.currentStepOf(3)).to.eq(2);
        });

        it('displays the correct amount', function(){
          expect($('.fundraiser-bar__display-amount').text()).to.eq('$17');
        });

        it('displays the second step', function(){
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
      });
    });

    describe('outstanding fields has elements', function(){

      describe('amount is not passed', function(){

        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: ['email'] });
        });

        it('starts on the first step', function(){
          expect(helpers.currentStepOf(3)).to.eq(1);
        });

        it('displays the second step', function(){
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
      });

      describe('amount is greater than zero', function(){

        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: ['email'], amount: 17 });
        });

        it('skips to the second step', function(){
          expect(helpers.currentStepOf(3)).to.eq(2);
        });

        it('displays the correct amount', function(){
          expect($('.fundraiser-bar__display-amount').text()).to.eq('$17');
        });

        it('displays the second step', function(){
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
      });

      it('prefills with values of member', function(){
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ member: {email: 'neal@test.com'}, outstandingFields: ['name'], amount: 17 });
        expect($('input[name="email"]').val()).to.eql('neal@test.com');
      });

      it('does not prefill if value is in outstandingFields', function(){
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ member: {email: 'neal@test.com'}, outstandingFields: ['email'], amount: 17 });
        expect($('input[name="email"]').val()).to.eql('');
      });

      it('does not hide the form fields', function(){
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ member: {email: 'neal@test.com'}, outstandingFields: ['name'], amount: 17 });
        var classed = $('.petition-bar__field-container').map(function(ii, el){
          return $(el).hasClass('form__group--prefilled');
        }).toArray();
        expect(classed).to.eql([false]);
      });
    });

    describe('degenerate arguments', function(){

      describe('it starts on first step when amount', function(){
        it('is negative', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: -1 });
          expect(helpers.currentStepOf(3)).to.eq(1)
        });
        it('is zero', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: 0 });
          expect(helpers.currentStepOf(3)).to.eq(1)
        });
        it('is a string', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: "hi" });
          expect(helpers.currentStepOf(3)).to.eq(1)
        });
        it('is null', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: null });
          expect(helpers.currentStepOf(3)).to.eq(1)
        });
        it('is an array', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: [3, 4, 5] });
          expect(helpers.currentStepOf(3)).to.eq(1)
        });
      });

      it ('starts on second step when amount is numeric string', function(){
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: "3" });
        expect(helpers.currentStepOf(3)).to.eq(2)
      });

      describe('shows second step when outstandingFields', function(){
        it('is an object', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: {first: 'second'} });
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
        it('is null', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: null });
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
        it('is a number', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: 0 });
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
        it('is a string', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: 'yooo' });
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
        it('is a numeric string', function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ outstandingFields: '5' });
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
      });
    });

  });

  describe('interactions', function(){

    beforeEach(function() {

      suite.follow_up_url = "/pages/636/follow-up";
      suite.fundraiserBar = new window.sumofus.FundraiserBar({ pageId: '1', followUpUrl: suite.follow_up_url });
      sinon.stub(suite.fundraiserBar, 'redirectTo');
      suite.server.respond(); // respond to request for token
    });

    afterEach(function() {
      suite.fundraiserBar.redirectTo.restore();
    });

    describe('loading and first panel', function(){

      it("starts on the first step", function() {
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

      it('changes the buttons to the right band when currency changes', function(){
        suite.fundraiserBar.donationBands['GBP'] = [1, 2, 3, 4, 5, 6, 7];
        $('.fundraiser-bar__currency-selector').val('GBP').change();
        var $buttons = $('.fundraiser-bar__amount-button');
        var texts = $buttons.map(function(ii, el){ return $(el).text() }).toArray();
        var vals =  $buttons.map(function(ii, el){ return $(el).data('amount'); }).toArray();
        expect($buttons.length).to.equal(7);
        expect(texts).to.include.members(['£1', '£2', '£3', '£4', '£5', '£6', '£7']);
        expect(vals).to.include.members([1, 2, 3, 4, 5, 6, 7]);
      });

      it('shows the selector when prompted', function(){
        var $selector = $('.fundraiser-bar__currency-selector');
        expect($selector).to.have.css('display','none');
        $('.fundraiser-bar__engage-currency-switcher').click();
        expect($selector).not.to.have.css('display','none');
      });

      it('changes the reported currency code when currency changes', function(){
        expect($('.fundraiser-bar__current-currency').text()).to.equal('USD');
        $('.fundraiser-bar__currency-selector').val('AUD').change();
        expect($('.fundraiser-bar__current-currency').text()).to.equal('AUD');
      });

      it('changes the filled in currency symbol when clicking in', function(){
        $('.fundraiser-bar__currency-selector').val('GBP').change();
        var $el = $('.fundraiser-bar__custom-field');
        expect($el).to.have.value('');
        $el.focus();
        expect($el).to.have.value('£');
      });

      it('displays the amount over step 1 with correct currency after moving on', function(){
        $('.fundraiser-bar__currency-selector').val('EUR').change();
        $('.fundraiser-bar__custom-field').val('$22');
        $('.fundraiser-bar__first-continue').click();
        expect($('.fundraiser-bar__display-amount').text()).to.eq('€22');
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
        $('.petition-bar__submit-button').click();
        var request = helpers.last(suite.server.requests);
        expect(request.method).to.eq("POST");
        expect(request.url).to.match(suite.validatePath);
      });

      it('moves to panel 3 if validation passes', function(){
        $('.petition-bar__submit-button').click();
        helpers.last(suite.server.requests).respond(200, { "Content-Type": "application/json" }, '{}');
        expect(helpers.currentStepOf(3)).to.eq(3);
      });

      it('stays on panel 2 if validation fails', function(){
        $('.petition-bar__submit-button').click();
        helpers.last(suite.server.requests).respond(422, { "Content-Type": "application/json" }, '{ "errors": {} }');
        expect(helpers.currentStepOf(3)).to.eq(2);
      });
    });

    describe('third panel', function() {

      beforeEach(function(){
        suite.server.respondWith("POST", this.validatePath, ["200", {}, ""]);
        $('.fundraiser-bar__custom-field').val('$22');
        $('.fundraiser-bar__first-continue').click();
        $('.petition-bar__submit-button').click();

        suite.server.respond();
        expect(helpers.currentStepOf(3)).to.eq(3);
      });

      it('disables the button when the form submits', function(){
        var $button = $('.fundraiser-bar__submit-button');
        expect($button).not.to.have.class('button--disabled');
        $button.click();
        expect($button).to.have.class('button--disabled');
      });

      it('sends the nonce to the server after receiving it from braintree', function(){
        suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
        request = helpers.last(suite.server.requests);
        expect(request.method).to.eq("POST");
        expect(request.url).to.eq("/api/braintree/pages/1/transaction");

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

      it('submits the currency and amount to the server', function(){
        suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
        request = helpers.last(suite.server.requests);
        bodyPairs = decodeURI(request.requestBody).split('&');
        expect(bodyPairs).to.include.members(['currency=USD', "amount=22"]);
      });

      it('loads the follow-up url after success from the server', function(){
        suite.server.respondWith('POST', "/api/braintree/pages/1/transaction",
          [200, { "Content-Type": "application/json" }, '{ "success": "true" }' ]);
        suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
        suite.server.respond();
        expect(suite.fundraiserBar.redirectTo).to.have.been.calledWith(suite.follow_up_url);
      });

      it('displays a generic validation error when server 500', function(){
        expect($('.fundraiser-bar__errors')).to.have.class('hidden-closed');
        suite.server.respondWith('POST', "/api/braintree/pages/1/transaction",
          [500, { "Content-Type": "application/json" }, 'Failure!' ]);
        suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
        suite.server.respond();
        expect($('.fundraiser-bar__errors')).not.to.have.class('hidden-closed');
        expect($('.fundraiser-bar__error-detail').length).to.equal(1);
        expect($('.fundraiser-bar__error-detail').text()).to.equal("Our technical team has been notified. Please double check your info or try a different payment method.")
      });

      it('shows a specific error for card decline', function(){
        expect($('.fundraiser-bar__errors')).to.have.class('hidden-closed');
        suite.server.respondWith('POST', "/api/braintree/pages/1/transaction",
          [422, { "Content-Type": "application/json" }, '{"success":false,"errors":[{"declined":true,"code":"","message":"cvv"}]}' ]);
        suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
        suite.server.respond();
        expect($('.fundraiser-bar__errors')).not.to.have.class('hidden-closed');
        expect($('.fundraiser-bar__error-detail').length).to.equal(1);
        expect($('.fundraiser-bar__error-detail').text()).to.equal("Your card was declined by the payment processor. Please try a different payment method.")
      });

      it('shows the errors for any other error', function(){
        expect($('.fundraiser-bar__errors')).to.have.class('hidden-closed');
        suite.server.respondWith('POST', "/api/braintree/pages/1/transaction",
          [422, { "Content-Type": "application/json" }, '{"success":false,"errors":[{"code":"81501","attribute":"amount","message":"Amount cannot be negative."}, {"code":"81501","attribute":"amount","message":"Amount cannot be negative."}]}' ]);
        suite.fundraiserBar.fakeNonceSuccess({nonce: helpers.btNonce});
        suite.server.respond();
        expect($('.fundraiser-bar__errors')).not.to.have.class('hidden-closed');
        expect($('.fundraiser-bar__error-detail').length).to.equal(2);
        expect($('.fundraiser-bar__error-detail').first().text()).to.equal("Amount cannot be negative.")
      });

      it('grays out the paypal button once a card number are entered', function(){
        event = {type: 'fieldStateChange', target: {fieldKey: 'number'}, isEmpty: true};
        suite.fundraiserBar.braintreeSettings().hostedFields.onFieldEvent(event);
        expect($('#hosted-fields__paypal')).not.to.have.class('paypal--grayed-out');
        event.isEmpty = false
        suite.fundraiserBar.braintreeSettings().hostedFields.onFieldEvent(event);
        expect($('#hosted-fields__paypal')).to.have.class('paypal--grayed-out');
      });

      it('restores color to the paypal button after the card digits are deleted', function(){
        event = {type: 'fieldStateChange', target: {fieldKey: 'number'}, isEmpty: false};
        suite.fundraiserBar.braintreeSettings().hostedFields.onFieldEvent(event);
        expect($('#hosted-fields__paypal')).to.have.class('paypal--grayed-out');
        event.isEmpty = true
        suite.fundraiserBar.braintreeSettings().hostedFields.onFieldEvent(event);
        expect($('#hosted-fields__paypal')).not.to.have.class('paypal--grayed-out');
      });

      it('hides the credit card field when paypal calls onSuccess', function(){
        expect($('.hosted-fields__credit-card-fields')).not.to.have.css('display','none');
        suite.fundraiserBar.braintreeSettings().paypal.onSuccess('fake-nonce', 'user@test.com');
        expect($('.hosted-fields__credit-card-fields')).to.have.css('display','none');
      });

      it('shows the credit card fields when paypal canceled', function(){
        suite.fundraiserBar.braintreeSettings().paypal.onSuccess('fake-nonce', 'user@test.com');
        expect($('.hosted-fields__credit-card-fields')).to.have.css('display','none');
        suite.fundraiserBar.braintreeSettings().paypal.onCancelled();
        expect($('.hosted-fields__credit-card-fields')).not.to.have.css('display','none');
      });

    });
  });
});


