//= require member-facing

describe("Action form", function() {
  var suite = this;
  suite.timeout(20000);

  beforeEach(function(){
    MagicLamp.wish("pages/petition");
    suite.fullVals = {
      email: 'starman@bowie.com',
      name: 'David Bowie',
      country: 'GB',
      welcome_name: 'David Bowie',
      phone: "213-7212-9087",
      voter: true,
      hair_color: 'dyed'
    };
    suite.inputs = $('.action-form__field-container').find('input.form__content, select.form__content');
  });

  describe('prefill', function(){
    it('does not prefill if skipPrefill flag is passed', function(){

    });

    describe('outstanding fields is empty', function(){

      describe('member is not passed', function(){

        beforeEach(function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: []});
        });

        it('does not prefill values', function(){
          var vals = suite.inputs.map(function(ii, el){ return $(el).val() }).toArray();
          expect(vals).to.eql(['', '', '', '']);
        });

        it('does not display the clearer', function(){
          expect($('.action-form__welcome-text')).to.have.class('hidden-irrelevant');
        });
      });

      describe('member is passed', function(){

        it('ignores extraneous member values', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: {email: 'neal@test.com', oogle: 'boogle'} });
          expect($('input[name="email"]').val()).to.eql('neal@test.com');
        });

        it('displays the clearer when form has fields', function(){
          expect($('.action-form .action-form__field-container').length).to.be.at.least(1);
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: suite.fullVals });
          expect($('.action-form__welcome-text')).not.to.have.class('hidden-irrelevant');
          expect($('.action-form__welcome-name')).to.have.text('David Bowie');
        });

        it('does not display the clearer when form has no fields', function(){
          $('.action-form__field-container').remove();
          expect($('.action-form .action-form__field-container').length).to.eq(0);
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: suite.fullVals });
          expect($('.action-form__welcome-text')).to.have.class('hidden-irrelevant');
        });

        it('prefills with values of member', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: suite.fullVals });
          var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
          expect(vals).to.eql( ['starman@bowie.com', 'David Bowie', 'GB', "213-7212-9087"]);
        });

        it('hides form fields when all filled', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: suite.fullVals });
          var classed = $('.action-form__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([true, true, true, true]);
        });

        it('does not hide empty form fields', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: {email: 'neal@test.com'} });
          var classed = $('.action-form__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([true, false, false, false]);
        });

        it('reveals the form fields properly', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: {email: 'neal@test.com'} });
          $('.action-form__clear-form').click();
          var classed = $('.action-form__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });

        it('overrides location country with member country', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: suite.fullVals, location: {country: 'NI'} });
          expect(suite.inputs.filter('[name="country"]').val()).to.eq('GB');
        });

        it('falls back to location country when member country not provided', function(){
          delete suite.fullVals['country'];
          suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: suite.fullVals, location: {country: 'NI'} });
          expect(suite.inputs.filter('[name="country"]').val()).to.eq('NI');
        });
      });
    });

    describe('outstanding fields has elements', function(){

      describe('member is passed', function(){

        it('does not prefill if value is in outstandingFields', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: ['email'], member: suite.fullVals});
          var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
          expect(vals).to.eql( ['', 'David Bowie', 'GB', "213-7212-9087"]);
        });

        it('does not hide the form fields', function(){
          suite.form = new window.champaign.ActionForm({ member: {email: 'neal@test.com'}, outstandingFields: ['name'], amount: 17 });
          var classed = $('.action-form__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });

        it('uses location country when country in outstandingFields', function(){
          suite.form = new window.champaign.ActionForm({ outstandingFields: ['country'], member: suite.fullVals, location: {country: 'NI'} });
          expect(suite.inputs.filter('[name="country"]').val()).to.eq('NI');
        });
      });

      describe('member is not passed', function(){

        it('does not prefill', function(){
          suite.form = new window.champaign.ActionForm({ member: {email: 'neal@test.com'}, outstandingFields: ['email'], amount: 17 });
          expect($('input[name="email"]').val()).to.eql('');
        });

        it('does not hide the form fields', function(){
          suite.form = new window.champaign.ActionForm({ member: {email: 'neal@test.com'}, outstandingFields: ['name'], amount: 17 });
          var classed = $('.action-form__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });
      });
    });

    describe('outstanding fields is not passed', function(){

      describe('member is not passed', function(){

        beforeEach(function(){
          suite.form = new window.champaign.ActionForm();
        });

        it('does not display the clearer', function(){
          expect($('.action-form__welcome-text')).to.have.class('hidden-irrelevant');
        });

        it('does not prefill', function(){
          expect($('input[name="email"]').val()).to.eql('');
        });

        it('does not hide the form fields', function(){
          var classed = $('.action-form__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });
      });

      describe('member is passed', function(){

        beforeEach(function(){
          suite.form = new window.champaign.ActionForm({member: suite.fullVals});
        });

        it('does not display the clearer', function(){
          expect($('.action-form__welcome-text')).to.have.class('hidden-irrelevant');
          expect($('.action-form__welcome-text')).to.have.class('hidden-irrelevant');
        });

        it('prefills with values of member', function(){
          var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
          expect(vals).to.eql( ['starman@bowie.com', 'David Bowie', 'GB', "213-7212-9087"]);
        });

        it('does not hide the form fields', function(){
          var classed = $('.action-form__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });
      });
    });
  });

  describe('selectize', function(){
    it ('selectizes the dropdown when not on mobile', function(){
      expect($('select')).not.to.have.class('selectized');
      $('.mobile-indicator').css('display', 'none');
      suite.form = new window.champaign.ActionForm();
      expect($('select')).to.have.class('selectized');
    });

    it ('does not selectize the dropdown when on mobile', function(){
      expect($('select')).not.to.have.class('selectized');
      $('.mobile-indicator').css('display', 'block');
      suite.form = new window.champaign.ActionForm();
      expect($('select')).not.to.have.class('selectized');
    });
  });

  describe('adding akid', function(){
    var akidFieldSelector = 'form.action-form input[type="hidden"][name="akid"]';

    it('adds a hidden field for akid if akid passed', function(){
      expect($(akidFieldSelector).length).to.eq(0);
      suite.form = new window.champaign.ActionForm({akid: '1234.5678.9887'});
      expect($(akidFieldSelector).length).to.eq(1);
    });

    it('does not add a hidden field if akid not passed', function(){
      expect($(akidFieldSelector).length).to.eq(0);
      suite.form = new window.champaign.ActionForm();
      expect($(akidFieldSelector).length).to.eq(0);
    });
  });

  describe('adding source', function(){
    var sourceFieldSelector = 'form.action-form input[type="hidden"][name="source"]';

    it('adds a hidden field for source if source passed', function(){
      expect($(sourceFieldSelector).length).to.eq(0);
      suite.form = new window.champaign.ActionForm({source: 'facebook'});
      expect($(sourceFieldSelector).length).to.eq(1);
    });

    it('does not add a hidden field if source not passed', function(){
      expect($(sourceFieldSelector).length).to.eq(0);
      suite.form = new window.champaign.ActionForm();
      expect($(sourceFieldSelector).length).to.eq(0);
    });
  });

  describe('adding referrer_id', function(){
    var sourceFieldSelector = 'form.action-form input[type="hidden"][name="referrer_id"]';

    it('adds a hidden field for source if source passed', function(){
      expect($(sourceFieldSelector).length).to.eq(0);
      suite.form = new window.champaign.ActionForm({referrer_id: '1234567890'});
      expect($(sourceFieldSelector).length).to.eq(1);
    });

    it('does not add a hidden field if source not passed', function(){
      expect($(sourceFieldSelector).length).to.eq(0);
      suite.form = new window.champaign.ActionForm();
      expect($(sourceFieldSelector).length).to.eq(0);
    });
  });

  describe('clearing prefill', function(){

    beforeEach(function(){
      // do the prefill first and check it happened
      suite.form = new window.champaign.ActionForm({ outstandingFields: [], member: suite.fullVals });
      var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
      expect(vals).to.eql(['starman@bowie.com', 'David Bowie', 'GB', "213-7212-9087"]);
    });

    it('clears the prefill when the clear-form link is clicked', function(){
      $('.action-form__clear-form').click();
      var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
      expect(vals).to.eql( ['', '', '', '']);
    });

    it('hides the clear-form link when clear-form link is clicked', function(){
      expect($('.action-form__welcome-text')).not.to.have.class('hidden-irrelevant');
      $('.action-form__clear-form').click();
      expect($('.action-form__welcome-text')).to.have.class('hidden-irrelevant');
    });

    it('clears the prefill when the form:clear event fires', function(){
      Backbone.trigger('form:clear')
      var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
      expect(vals).to.eql( ['', '', '', '']);
    });

    it('hides the clear-form link when form:clear event fires', function(){
      expect($('.action-form__welcome-text')).not.to.have.class('hidden-irrelevant');
      Backbone.trigger('form:clear')
      expect($('.action-form__welcome-text')).to.have.class('hidden-irrelevant');
    });
  });

  describe('form response', function(){
    it('displays errors when the ajax call fails', function(){
      suite.form = new window.champaign.ActionForm();
      $('form.action-form').trigger('ajax:error', {status: 422, responseText: '{"errors": {"name": ["must have three letters"]}}'});
      expect($('form.action-form .error-msg').length).to.eq(1);
    });

    it('triggers form:submitted when the response succeeds', function(){
      sinon.stub(Backbone, 'trigger');
      suite.form = new window.champaign.ActionForm();
      $('form.action-form').trigger('ajax:success');
      expect(Backbone.trigger).to.have.been.calledWith('form:submitted');
    });
  });

});
