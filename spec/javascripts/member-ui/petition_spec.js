//= require sumofus

describe("Petition", function() {
  var suite = this;
  suite.timeout(20000);

  beforeEach(function(){
    MagicLamp.wish("pages/petition");
  });

  describe('submission success', function(){

    beforeEach(function(){
      suite.followUpUrl = "/pages/636/follow-up";
      suite.callback = sinon.spy();
    });

    it('redirects to the followUpUrl if it is supplied', function(){
      suite.petition = new window.sumofus.Petition({followUpUrl: suite.followUpUrl});
      sinon.stub(suite.petition, 'redirectTo');
      $.publish('form:submitted');
      expect(suite.petition.redirectTo).to.have.been.calledWith(suite.followUpUrl);
      suite.petition.redirectTo.restore();
    });

    it('calls the callback function if it is supplied', function(){
      var callback = sinon.spy();
      new window.sumofus.Petition({submissionCallback: callback});
      $.publish('form:submitted');
      expect(callback.called).to.eq(true);
    });

    it('calls the callback function and redirects to the followUpUrl if both supplied', function(){
      var callback = sinon.spy();
      suite.petition = new window.sumofus.Petition({submissionCallback: callback, followUpUrl: suite.followUpUrl});
      sinon.stub(suite.petition, 'redirectTo');
      $.publish('form:submitted');
      expect(suite.petition.redirectTo).to.have.been.calledWith(suite.followUpUrl);
      expect(callback.called).to.eq(true);
      suite.petition.redirectTo.restore();
    });

    it('sends an alert if neither callback nor followUpUrl passed', function(){
      window.alert = sinon.spy();
      suite.petition = new window.sumofus.Petition();
      $.publish('form:submitted');
      expect(window.alert.called).to.eq(true);
    });
  });
});
