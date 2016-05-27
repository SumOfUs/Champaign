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

    describe('currency', function(){
      it('sets the default currency if currency passed', function(){
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ currency: 'GBP'});
        expect($('.fundraiser-bar__currency-selector').val()).to.equal('GBP');
      });

      it('sets the default currency if currency passed as lowercase', function(){
        suite.fundraiserBar = new window.sumofus.FundraiserBar({ currency: 'gbp'});
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
    });


    describe('action-form is prefilled', function(){

      beforeEach(function(){
        $('.fundraiser-bar .action-form').data('prefilled', true);
      });

      describe('amount is not passed', function(){
        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar();
        });

        it('displays the second step when user clears form', function(){
          $('.fundraiser-bar__amount-button').first().click();
          expect(helpers.currentStepOf(3)).to.eq(3);
          $('.action-form__clear-form').click();
          expect(helpers.currentStepOf(3)).to.eq(2);
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });

        it('starts on the first step', function(){
          expect(helpers.currentStepOf(3)).to.eq(1);
        });

        it('hides the second step', function(){
          expect($('.fundraiser-bar__step-label[data-step="2"]')).to.have.css('visibility', 'hidden');
        });

        it('skips to the third step when an amount is clicked', function(){
          $('.fundraiser-bar__amount-button').first().click();
          expect(helpers.currentStepOf(3)).to.eq(3);
        });

      });

      describe('amount is greater than 0', function(){
        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({amount: 17});
        });

        it('skips to the third step', function(){
          expect(helpers.currentStepOf(3)).to.eq(3);
        });

        it('displays the correct amount', function(){
          expect($('.fundraiser-bar__display-amount').text()).to.eq('$17');
        });

        it('hides the second step', function(){
          expect($('.fundraiser-bar__step-label[data-step="2"]')).to.have.css('visibility', 'hidden');
        });

        it('displays the second step when user requests', function(){
          $('.action-form__clear-form').click();
          expect(helpers.currentStepOf(3)).to.eq(2);
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
      });
    });
 
    describe('action-form is not prefilled', function(){

      describe('amount is not passed', function(){
        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar();
        });

        it('starts on the first step', function(){
          expect(helpers.currentStepOf(3)).to.eq(1);
        });

        it('displays the second step', function(){
          expect($('.fundraiser-bar__step-label[data-step="2"]')).not.to.have.css('visibility', 'hidden');
        });
      });

      describe('amount is greater than 0', function(){
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

    describe('amount is degenerate', function(){

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
    });

    describe('recurring default', function(){
      describe('is "recurring"', function(){
        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: '3', recurringDefault: 'recurring'});
        });

        it('checks the recurring box', function(){
          expect($('input.fundraiser-bar__recurring').prop('checked')).to.eq(true);
        });

        it('does not hide the recurring box', function(){
          expect($('input.fundraiser-bar__recurring').parents('.form__group')).not.to.have.class('hidden-irrelevant');
        });

        it('adds "/ month" the button text', function(){
          expect($('.fundraiser-bar__submit-button').text().trim().replace(/\s+/g, ' ')).to.eq('Donate $3 / month');
        });
      });

      describe('is "only_recurring"', function(){
        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: '3', recurringDefault: 'only_recurring'});
        });

        it('checks the recurring box', function(){
          expect($('input.fundraiser-bar__recurring').prop('checked')).to.eq(true);
        });

        it('hides the recurring box', function(){
          expect($('input.fundraiser-bar__recurring').parents('.form__group')).to.have.class('hidden-irrelevant');
        });

        it('adds "/ month" the button text', function(){
          expect($('.fundraiser-bar__submit-button').text().trim().replace(/\s+/g, ' ')).to.eq('Donate $3 / month');
        });
      });

      describe('is "one_off"', function(){
        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: '3', recurringDefault: 'one_off'});
        });

        it('leaves the recurring box unchecked', function(){
          expect($('input.fundraiser-bar__recurring').prop('checked')).to.eq(false);
        });

        it('does not hide the recurring box', function(){
          expect($('input.fundraiser-bar__recurring').parents('.form__group')).not.to.have.class('hidden-irrelevant');
        });

        it('does not add "/ month" the button text', function(){
          expect($('.fundraiser-bar__submit-button').text().trim().replace(/\s+/g, ' ')).to.eq('Donate $3');
        });
      });

      describe('is an empty string', function(){
        beforeEach(function(){
          suite.fundraiserBar = new window.sumofus.FundraiserBar({ amount: '3', recurringDefault: ''});
        });

        it('leaves the recurring box unchecked', function(){
          expect($('input.fundraiser-bar__recurring').prop('checked')).to.eq(false);
        });

        it('does not hide the recurring box', function(){
          expect($('input.fundraiser-bar__recurring').parents('.form__group')).not.to.have.class('hidden-irrelevant');
        });

        it('does not add "/ month" the button text', function(){
          expect($('.fundraiser-bar__submit-button').text().trim().replace(/\s+/g, ' ')).to.eq('Donate $3');
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
        expect($('.fundraiser-bar__current-currency').text()).to.equal('Values shown in USD');
        $('.fundraiser-bar__currency-selector').val('AUD').change();
        expect($('.fundraiser-bar__current-currency').text()).to.equal('Values shown in AUD');
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
        $('.action-form__submit-button').click();
        var request = helpers.last(suite.server.requests);
        expect(request.method).to.eq("POST");
        expect(request.url).to.match(suite.validatePath);
      });

      it('moves to panel 3 if validation passes', function(){
        $('.petition-bar__submit-button').click();
        $('form.action-form').trigger('ajax:success');
        expect(helpers.currentStepOf(3)).to.eq(3);
      });

      it('stays on panel 2 if validation fails', function(){
        $('.petition-bar__submit-button').click();
        $('form.action-form').trigger('ajax:error');
        expect(helpers.currentStepOf(3)).to.eq(2);
      });
    });

    describe('third panel', function() {

      beforeEach(function(){
        $('.fundraiser-bar__custom-field').val('$22');
        $('.fundraiser-bar__first-continue').click();
        $('form.action-form').trigger('ajax:success');

        expect(helpers.currentStepOf(3)).to.eq(3);
      });

      it('disables the button when the form submits', function(){
        var $button = $('.fundraiser-bar__submit-button');
        expect($button).not.to.have.class('button--disabled');
        expect( $button.prop('disabled') ).to.eq(false);

        $button.click();

        expect($button).to.have.class('button--disabled');
        expect( $button.prop('disabled') ).to.eq(true);
      });

      it('sends the nonce to the server after receiving it from braintree', function(){
        Backbone.trigger('fundraiser:nonce_received', helpers.btNonce);
        request = helpers.last(suite.server.requests);
        expect(request.method).to.eq("POST");
        expect(request.url).to.eq("/api/payment/braintree/pages/1/transaction");
        expect(helpers.lastRequestBodyPairs(suite)).to.include.members(["payment_method_nonce="+helpers.btNonce, "amount=22"]);
      });

      it("sends 'recurring' as false by default", function(){
        Backbone.trigger('fundraiser:nonce_received', helpers.btNonce);
        expect(helpers.lastRequestBodyPairs(suite)).to.include.members(["recurring=false"]);
      });

      it("sends 'recurring' as true if it's checked", function(){
        $('input.fundraiser-bar__recurring').click();
        Backbone.trigger('fundraiser:nonce_received', helpers.btNonce);
        expect(helpers.lastRequestBodyPairs(suite)).to.include.members(["recurring=true"]);
      });

      it('submits the currency and amount to the server', function(){
        Backbone.trigger('fundraiser:nonce_received', helpers.btNonce);
        request = helpers.last(suite.server.requests);
        bodyPairs = decodeURI(request.requestBody).split('&');
        expect(bodyPairs).to.include.members(['currency=USD', "amount=22"]);
      });

      it('loads the follow-up url after success from the server', function(){
        suite.server.respondWith('POST', "/api/payment/braintree/pages/1/transaction",
          [200, { "Content-Type": "application/json" }, '{ "success": "true" }' ]);
        Backbone.trigger('fundraiser:nonce_received', helpers.btNonce);
        suite.server.respond();
        expect(suite.fundraiserBar.redirectTo).to.have.been.calledWith(suite.follow_up_url);
      });

    });
  });
});


