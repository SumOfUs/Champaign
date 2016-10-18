//= require member-facing

describe("Braintree hosted fields", function() {
  var suite = this;
  suite.timeout(20000);

  beforeEach(function() {
    MagicLamp.wish("pages/fundraiser");
    suite.validatePath = /\/api\/pages\/[0-9]+\/actions\/validate/;
    suite.server = sinon.fakeServer.create();
  });

  afterEach(function(){
    suite.server.restore();
  });

  describe('with successful token', function(){
    beforeEach(function(){
      suite.server.respondWith("GET", '/api/braintree/token',
                              [200, { "Content-Type": "application/json" },
                              '{ "token": "'+helpers.btClientToken+'" }' ]);
      suite.hostedFields = new window.champaign.BraintreeHostedFields();
      suite.server.respond();
    });

    it('grays out the paypal and direct debit buttons once a card number is entered', function(){
      event = {type: 'fieldStateChange', target: {fieldKey: 'number'}, isEmpty: true};
      suite.hostedFields.braintreeSettings().hostedFields.onFieldEvent(event);
      expect($('#hosted-fields__paypal')).not.to.have.class('hosted-fields--grayed-out');
      expect($('.hosted-fields__direct-debit-container')).not.to.have.class('hosted-fields--grayed-out');
      event.isEmpty = false
      suite.hostedFields.braintreeSettings().hostedFields.onFieldEvent(event);
      expect($('#hosted-fields__paypal')).to.have.class('hosted-fields--grayed-out');
      expect($('.hosted-fields__direct-debit-container')).to.have.class('hosted-fields--grayed-out');
    });

    it('restores color to the paypal and direct debit buttons after the card digits are deleted', function(){
      event = {type: 'fieldStateChange', target: {fieldKey: 'number'}, isEmpty: false};
      suite.hostedFields.braintreeSettings().hostedFields.onFieldEvent(event);
      expect($('#hosted-fields__paypal')).to.have.class('hosted-fields--grayed-out');
      expect($('.hosted-fields__direct-debit-container')).to.have.class('hosted-fields--grayed-out');
      event.isEmpty = true
      suite.hostedFields.braintreeSettings().hostedFields.onFieldEvent(event);
      expect($('#hosted-fields__paypal')).not.to.have.class('hosted-fields--grayed-out');
      expect($('.hosted-fields__direct-debit-container')).not.to.have.class('hosted-fields--grayed-out');
    });

    it('hides the credit card field when paypal calls onSuccess', function(){
      expect($('.hosted-fields__credit-card-fields')).not.to.have.css('display','none');
      suite.hostedFields.braintreeSettings().paypal.onSuccess('fake-nonce', 'user@test.com');
      expect($('.hosted-fields__credit-card-fields')).to.have.css('display','none');
    });

    it('shows the credit card fields when paypal canceled', function(){
      suite.hostedFields.braintreeSettings().paypal.onSuccess('fake-nonce', 'user@test.com');
      expect($('.hosted-fields__credit-card-fields')).to.have.css('display','none');
      suite.hostedFields.braintreeSettings().paypal.onCancelled();
      expect($('.hosted-fields__credit-card-fields')).not.to.have.css('display','none');
    });
  });

  it('displays the fields container when token received and assigns deviceData', function(){
    expect($('.fundraiser-bar__fields-loading')).not.to.have.class('hidden-closed');
    expect($('#hosted-fields')).to.have.class('hidden-closed');
    suite.hostedFields = new window.champaign.BraintreeHostedFields();
    suite.hostedFields.braintreeSettings().onReady({deviceData: '1234'});
    expect($('.fundraiser-bar__fields-loading')).to.have.class('hidden-closed');
    expect($('#hosted-fields')).not.to.have.class('hidden-closed');
    expect(suite.hostedFields.deviceData).to.eq('1234')
  });
});
