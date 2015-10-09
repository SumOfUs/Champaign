let PageEditBar = Backbone.View.extend({

  el: '.page-edit-bar',

  events: {
    'click .action-bar__open-button': 'reveal',
  },

  initialize: function() {
    $('.page-edit-step').each((ii, step) => {
      this.addStepToSidebar($(step));
    })
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },

  addStepToSidebar: function($step) {
    let $ul = this.$('ul.page-edit-bar__step-list');
    const title = $step.find('.page-edit-step__title').text();
    const id = $step.attr('id');
    const li = `<a href="#${id}"><li>${title}</li></a>`;
    console.log(li, $ul.length)
    $ul.append(li);
  }

});

module.exports = PageEditBar;
