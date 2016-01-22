let ErrorDisplay = require('show_errors');

let PageModel = Backbone.Model.extend({
  urlRoot: '/api/pages',

  initialize: function(){
    this.lastSaved = null;
  },

  // override save to only actually save if it's new data
  save: function(data, callbacks) {
    if (_.isEqual(data, this.lastSaved)) {
      if (typeof callbacks.unchanged === 'function') {
        callbacks.unchanged();
      }
    } else {
      this.lastSaved = data;
      Backbone.Model.prototype.save.apply(this, arguments)
    }
  }

});


let PageEditBar = Backbone.View.extend({

  el: '.page-edit-bar',

  events: {
    'click .page-edit-bar__save-button': 'save',
    'click .page-edit-bar__error-message': 'findError',
    'click .page-edit-bar__toggle-autosave>.toggle-button': 'toggleAutosave',
  },

  initialize: function() {
    this.outstandingSaveRequest = false;
    this.addStepsToSidebar();
    this.model = new PageModel();
    this.setupAutosave();
    this.$saveBtn = this.$('.page-edit-bar__save-button');
    $('body').scrollspy({ target: '.scrollspy', offset: 150});
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },

  addStepsToSidebar: function() {
    const $existing = $('ul.page-edit-bar__step-list li');
    $('.page-edit-step').each((ii, step) => {
      this.addStepToSidebar($(step));
    });
    $existing.remove();
    this.$('ul.page-edit-bar__step-list').append($existing);
  },

  addStepToSidebar: function($step) {
    let $ul = this.$('ul.page-edit-bar__step-list');
    const title = $step.find('.page-edit-step__title')[0].childNodes[0].nodeValue.trim();
    const id = $step.attr('id');
    const icon = $step.data('icon') || 'cubes';
    const link_href = $step.data('link-to') ? $step.data('link-to') : `#${id}`;
    const link_target = $step.data('link-to') ? "_blank" : "_self";
    const li = `<li><a href="${link_href}" target="${link_target}"><i class="fa fa-${icon}"></i>${title}</a></li>`;
    $ul.append(li);
  },

  readData: function(){
    let data = {}
    $('form.one-form').each((ii, form) => {
      let $form = $(form);
      let type = $form.data('type') || 'base';
      if (!data.hasOwnProperty(type)) {
        data[type] = {}
      } 
      $.extend(data[type], this.serializeForm($form))
    });
    data.id = data.page['page[id]'];
    return data;
  },

  serializeForm: function($form){
    let data = {}
    _.each($form.serializeArray(), function(pair) {
      // this is to handle form arrays cause their name ends in []
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
    if (!this.outstandingSaveRequest) {
      this.disableSubmit();
      this.model.save(this.readData(), {success: this.saved(), error: this.saveFailed(), unchanged: this.saveUnchanged()});
    }
  },

  saveUnchanged: function (){
    return () => { this.enableSubmit(); }
  },

  saved: function() {
    return (e, data) => { // closure for `this` cause it's an event callback
      if (data.refresh){ location.reload(); }
      this.enableSubmit();
      $.publish('page:saved', data);
      let now = new Date();
      $('.page-edit-bar__save-box').removeClass('page-edit-bar__save-box--has-error');
      $('.page-edit-bar__error-message').text('');
      $('.page-edit-bar__last-saved').text(`Last saved at ${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`);
    }
  },

  saveFailed: function() {
    return (e, data) => { // closure for `this` cause it's an event callback
      console.log("save failed with", e, data);
      this.enableSubmit();
      $('.page-edit-bar__save-box').addClass('page-edit-bar__save-box--has-error')
      if(data.status == 422) {
        ErrorDisplay.show(e, data);
        $('.page-edit-bar__error-message').text("The server didn't like something you entered. Click here to see the error.");
        $.publish('page:errors');
      } else {
        $('.page-edit-bar__error-message').text("The server unexpectedly messed up saving your work.");
      }
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
    if (e) { e.preventDefault(); }
    this.autosave = !this.autosave;
    this.$('.page-edit-bar__toggle-autosave').find('.toggle-button').toggleClass('btn-primary');
    if(this.autosave) {
      this.$('.page-edit-bar__btn-holder').addClass('page-edit-bar__btn-holder--hidden');
    } else {
      this.$('.page-edit-bar__btn-holder').removeClass('page-edit-bar__btn-holder--hidden');
    }
  },

  disableSubmit: function(){
    this.outstandingSaveRequest = true;
    this.$saveBtn.text('Saving...');
    this.$saveBtn.addClass('disabled');
  },

  enableSubmit: function(){
    this.outstandingSaveRequest = false;
    this.$saveBtn.text('Save my work');
    this.$saveBtn.removeClass('disabled');
  },

  setupAutosave: function() {
    const SAVE_PERIOD = 5000; // milliseconds
    const shouldAutosave = (this.$('.page-edit-bar__toggle-autosave').data('autosave') == true);
    this.autosave = true;
    if (shouldAutosave != this.autosave) {
      this.toggleAutosave();
    }
    window.setInterval(() => {
      if(this.autosave) {
        this.save();
      }
    }, SAVE_PERIOD)
  },

});

module.exports = PageEditBar;
