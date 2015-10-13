// window.PageModel = require('page_model');

let PageModel = Backbone.Model.extend({
  urlRoot: '/api/pages',
});


let PageEditBar = Backbone.View.extend({

  el: '.page-edit-bar',

  events: {
    'click .page-edit-bar__save-button': 'save',
    'click .page-edit-bar__message': 'findError',
  },

  initialize: function() {
    $('.page-edit-step').each((ii, step) => {
      this.addStepToSidebar($(step));
    });
    this.model = new PageModel();
    $('body').scrollspy({ target: '.scrollspy', offset: 150});
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },

  addStepToSidebar: function($step) {
    let $ul = this.$('ul.page-edit-bar__step-list');
    const title = $step.find('.page-edit-step__title').text();
    const id = $step.attr('id');
    const icon = $step.data('icon') || 'cubes'
    const li = `<li><a href="#${id}"><i class="fa fa-${icon}"></i>${title}</a></li>`;
    $ul.append(li);
  },

  readData: function(){
    let data = {}
    $('form.one-form').each(function(ii, form){
      _.each($(form).serializeArray(), function(pair) {
        data[pair.name] = pair.value;
      });
    });
    data.id = data['page[id]'];
    console.log(data);
    return data;
  },

  save: function() {
    this.model.save(this.readData(), {success: this.saved, error: this.saveFailed});
  },

  saved: function() {
    $('.page-edit-bar__save-box').removeClass('page-edit-bar__save-box--has-error');
    $('.page-edit-bar__save-box').addClass('page-edit-bar__save-box--success');
    $('.page-edit-bar__message').text('Saved successfully!');
    window.setTimeout(function(){
      $('.page-edit-bar__save-box').removeClass('page-edit-bar__save-box--success');
      $('.page-edit-bar__message').text('');
    }, 2000)
  },

  saveFailed: function(e, data) {
    console.log("save failed with", e, data);
    $('.page-edit-bar__save-box').addClass('page-edit-bar__save-box--has-error')
    if(data.status == 422) {
      Champaign.showErrors(e, data);
      $('.page-edit-bar__message').text("The server didn't like something you entered. Click here to see the error.");
    } else {
      $('.page-edit-bar__message').text("The server unexpectedly messed up saving your work.");
    }
  },

  findError: function(){
    if (this.$('.page-edit-bar__save-box').hasClass('page-edit-bar__save-box--has-error')) {
      if ($('.has-error').length > 0) {
        $('html, body').animate({
            scrollTop: $('.has-error').first().offset().top
        }, 500);
      }
    }
  },

});

module.exports = PageEditBar;
