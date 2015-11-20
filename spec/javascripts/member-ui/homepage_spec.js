//= require sumofus

describe("fundraiser", function() {

  beforeEach(function() {
    MagicLamp.wish("pages/fundraiser");
  });

  it("shows only the first two panels of the donate panel", function() {
    var myFundraiserBar = new window.FundraiserBar("/pages/636/follow-up");
    expect($('.fundraiser-bar .fundraiser-bar__step-panel[data-step="1"]').
              hasClass('hidden-closed')).to.equal(false);
    expect($('.fundraiser-bar .fundraiser-bar__step-panel[data-step="2"]').
              hasClass('hidden-closed')).to.equal(true);
    expect($('.fundraiser-bar .fundraiser-bar__step-panel[data-step="3"]').
              hasClass('hidden-closed')).to.equal(true);
  });

});
