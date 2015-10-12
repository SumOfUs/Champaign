// window.PageModel = require('page_model');

let PageModel = Backbone.Model.extend({
  urlRoot: '/api/pages',
});


let PageEditBar = Backbone.View.extend({

  el: '.page-edit-bar',

  events: {
    'click .page-edit-bar__save-button': 'save'
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
    console.log("saved successfully!");
  },

  saveFailed: function(a, err) {
    console.log("save failed with", a, err);
  },

});

module.exports = PageEditBar;
