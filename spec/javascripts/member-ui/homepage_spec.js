//= require sumofus

describe("fundraiser", function() {

  beforeEach(function() {
    MagicLamp.wish("pages/fundraiser");
    var myFundraiserBar = new window.FundraiserBar("/pages/636/follow-up");
  });


  describe('loading and first panel', function(){
    it("shows only the first two panels of the donate panel", function() {
      expect($('.fundraiser-bar__step-panel[data-step="1"]')).not.to.have.class('hidden-closed');
      expect($('.fundraiser-bar__step-panel[data-step="2"]')).to.have.class('hidden-closed');
      expect($('.fundraiser-bar__step-panel[data-step="3"]')).to.have.class('hidden-closed');
    });

    it('does not display the "next" button', function(){});
    it('autofills the custom amount with a dollar sign', function(){});
    it('reveals the "next" button when a custom amount is entered', function(){});
    it('moves to step 2 when next clicked with custom amount', function(){});
    it('moves to step 2 when amount button clicked', function(){});
    it('does not move to step 2 if custom amount has only dollar sign', function(){});
    it('displays the amount over step 1 after moving ahead', function(){});
  });

  describe('second panel', function(){

    beforeEach(function(){
      // $('')
    });

    // most of the interaction on the form are on the form js, which is beyond the scope
    // of this test suite
    it('makes a request to validate the form', function(){});
    it('stays on panel 2 if validation fails', function(){});
    it('moves to panel 3 if validation passes', function(){});
    it('returns to panel 1 if number 1 is clicked', function(){});
  });

});
