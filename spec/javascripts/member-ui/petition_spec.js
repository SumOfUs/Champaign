//= require sumofus

describe("Petition", function() {
  var suite = this;
  suite.timeout(20000);

  before(function() {
    window.onbeforeunload = function(){
      // the javascript has redirects, this prevents them firing if you view the tests in browser
      return 'Are you sure you want to leave?';
    };
  });

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
    suite.inputs = $('.petition-bar__field-container').find('input.form__content, select.form__content');
  });

  describe('instantiation', function(){

    describe('selective', function(){
      it ('selectizes the dropdown when not on mobile', function(){
        expect($('select')).not.to.have.class('selectized');
        $('.mobile-indicator').css('display', 'none');
        suite.petitionBar = new window.sumofus.PetitionBar();
        expect($('select')).to.have.class('selectized');
      });

      it ('does not selectize the dropdown when on mobile', function(){
        expect($('select')).not.to.have.class('selectized');
        $('.mobile-indicator').css('display', 'block');
        suite.petitionBar = new window.sumofus.PetitionBar();
        expect($('select')).not.to.have.class('selectized');
      });
    });

    describe('outstanding fields is empty', function(){

      describe('member is not passed', function(){

        beforeEach(function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: []});
        });

        it('does not prefill values', function(){
          var vals = suite.inputs.map(function(ii, el){ return $(el).val() }).toArray();
          expect(vals).to.eql(['', '', '', '']);
        });

        it('does not display the clearer', function(){
          expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
        });
      });

      describe('member is passed', function(){

        it('ignores extraneous member values', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: {email: 'neal@test.com', oogle: 'boogle'} });
          expect($('input[name="email"]').val()).to.eql('neal@test.com');
        });

        it('displays the clearer when form has fields', function(){
          expect($('.petition-bar .petition-bar__field-container').length).to.be.at.least(1);
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: suite.fullVals });
          expect($('.petition-bar__welcome-text')).not.to.have.class('hidden-irrelevant');
          expect($('.petition-bar__welcome-name')).to.have.text('David Bowie');
        });

        it('does not display the clearer when form has no fields', function(){
          $('.petition-bar__field-container').remove();
          expect($('.petition-bar .petition-bar__field-container').length).to.eq(0);
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: suite.fullVals });
          expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
        });

        it('prefills with values of member', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: suite.fullVals });
          var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
          expect(vals).to.eql( ['starman@bowie.com', 'David Bowie', 'GB', "213-7212-9087"]);
        });

        it('hides the form fields', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: {email: 'neal@test.com'} });
          var classed = $('.petition-bar__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([true, true, true, true]);
        });

        it('reveals the form fields properly', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: {email: 'neal@test.com'} });
          $('.petition-bar__clear-form').click();
          var classed = $('.petition-bar__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });

        it('clears prefilled fields properly', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: suite.fullVals });
          $('.petition-bar__clear-form').click();
          var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
          expect(vals).to.eql( ['', '', '', '']);
        });

        it('overrides location country with member country', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: suite.fullVals, location: {country: 'NI'} });
          expect(suite.inputs.filter('[name="country"]').val()).to.eq('GB');
        });

        it('falls back to location country when member country not provided', function(){
          delete suite.fullVals['country'];
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: [], member: suite.fullVals, location: {country: 'NI'} });
          expect(suite.inputs.filter('[name="country"]').val()).to.eq('NI');
        });
      });
    });

    describe('outstanding fields has elements', function(){

      describe('member is passed', function(){

        it('does not prefill if value is in outstandingFields', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: ['email'], member: suite.fullVals});
          var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
          expect(vals).to.eql( ['', 'David Bowie', 'GB', "213-7212-9087"]);
        });

        it('does not hide the form fields', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ member: {email: 'neal@test.com'}, outstandingFields: ['name'], amount: 17 });
          var classed = $('.petition-bar__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });

        it('uses location country when country in outstandingFields', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ outstandingFields: ['country'], member: suite.fullVals, location: {country: 'NI'} });
          expect(suite.inputs.filter('[name="country"]').val()).to.eq('NI');
        });
      });

      describe('member is not passed', function(){

        it('does not prefill', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ member: {email: 'neal@test.com'}, outstandingFields: ['email'], amount: 17 });
          expect($('input[name="email"]').val()).to.eql('');
        });

        it('does not hide the form fields', function(){
          suite.petitionBar = new window.sumofus.PetitionBar({ member: {email: 'neal@test.com'}, outstandingFields: ['name'], amount: 17 });
          var classed = $('.petition-bar__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });
      });
    });

    describe('outstanding fields is not passed', function(){

      describe('member is not passed', function(){

        beforeEach(function(){
          suite.petitionBar = new window.sumofus.PetitionBar();
        });

        it('does not display the clearer', function(){
          expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
        });

        it('does not prefill', function(){
          expect($('input[name="email"]').val()).to.eql('');
        });

        it('does not hide the form fields', function(){
          var classed = $('.petition-bar__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });
      });

      describe('member is passed', function(){

        beforeEach(function(){
          suite.petitionBar = new window.sumofus.PetitionBar({member: suite.fullVals});
        });

        it('does not display the clearer', function(){
          expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
          expect($('.petition-bar__welcome-text')).to.have.class('hidden-irrelevant');
        });

        it('prefills with values of member', function(){
          var vals = suite.inputs.map(function(ii, el){ return $(el).val(); }).toArray();
          expect(vals).to.eql( ['starman@bowie.com', 'David Bowie', 'GB', "213-7212-9087"]);
        });

        it('does not hide the form fields', function(){
          var classed = $('.petition-bar__field-container').map(function(ii, el){
            return $(el).hasClass('form__group--prefilled');
          }).toArray();
          expect(classed).to.eql([false, false, false, false]);
        });
      });
    });


  });
});


