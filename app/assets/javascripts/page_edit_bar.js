// window.PageModel = require('page_model');

let PageModel = Backbone.Model.extend({
  urlRoot: '/api/pages',
});


let PageEditBar = Backbone.View.extend({

  el: '.page-edit-bar',

  events: {
    'click .page-edit-bar__save-button': 'save',
    'click .page-edit-bar__error-message': 'findError',
    'click .toggle-button': 'toggleAutosave',
  },

  initialize: function() {
    this.autosave = true;
    $('.page-edit-step').each((ii, step) => {
      this.addStepToSidebar($(step));
    });
    this.model = new PageModel();
    this.setupAutosave();
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
    $('form.one-form').each((ii, form) => {
      let $form = $(form);
      let type = $form.data('type') || 'base';
      console.log(data)
      if (!data.hasOwnProperty(type)) {
        console.log('new', type, data[type])
        data[type] = {}
      } 
      $.extend(data[type], this.serializeForm($form))
    });
    data.id = data.page['page[id]'];
    console.log(data);
    return data;
  },

  serializeForm: function($form){
    let data = {}
    _.each($form.serializeArray(), function(pair) {
      if (pair.name.endsWith('[]')) {
        let name = pair.name.slice(0, -2);
        if (!data.hasOwnProperty(name)) {
          data[name] = []
        }
        data[name].push(pair.value)
      } else {
        data[pair.name] = pair.value;
      }
    });
    return data;
  },

  save: function() {
    $.publish('quill_editor:submit'); // for quill to update content
    this.model.save(this.readData(), {success: this.saved, error: this.saveFailed});
  },

  saved: function() {
    $.publish('plugin:action:preview:update');
    let now = new Date();
    $('.page-edit-bar__save-box').removeClass('page-edit-bar__save-box--has-error');
    $('.page-edit-bar__error-message').text('');
    $('.page-edit-bar__last-saved').text(`Last saved at ${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`);
  },

  saveFailed: function(e, data) {
    console.log("save failed with", e, data);
    $('.page-edit-bar__save-box').addClass('page-edit-bar__save-box--has-error')
    if(data.status == 422) {
      Champaign.showErrors(e, data);
      $('.page-edit-bar__error-message').text("The server didn't like something you entered. Click here to see the error.");
    } else {
      $('.page-edit-bar__error-message').text("The server unexpectedly messed up saving your work.");
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

  toggleAutosave: function(e) {
    e.preventDefault();
    this.autosave = !this.autosave;
    this.$('.toggle-button').toggleClass('btn-primary');
    if(this.autosave) {
      this.$('.page-edit-bar__btn-holder').addClass('page-edit-bar__btn-holder--hidden');
    } else {
      this.$('.page-edit-bar__btn-holder').removeClass('page-edit-bar__btn-holder--hidden');
    }
  },

  setupAutosave: function() {
    const SAVE_PERIOD = 5000; // milliseconds
    window.setInterval(() => {
      if(this.autosave) {
        this.save();
      }
    }, SAVE_PERIOD)
  },

});

module.exports = PageEditBar;
