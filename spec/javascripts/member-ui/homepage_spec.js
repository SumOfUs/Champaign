//= require sumofus

describe("fundraiser", function() {

  beforeEach(function() {
    MagicLamp.wish("pages/fundraiser");
  });

  it("shows only the first two panels of the donate panel", function() {
    var myFundraiserBar = new window.FundraiserBar("/pages/636/follow-up");
    expect($('.fundraiser-bar__step-panel[data-step="1"]')).not.to.have.class('hidden-closed');
    expect($('.fundraiser-bar__step-panel[data-step="2"]')).to.have.class('hidden-closed');
    expect($('.fundraiser-bar__step-panel[data-step="3"]')).to.have.class('hidden-closed');
  });

});
