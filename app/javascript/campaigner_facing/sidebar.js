import setupOnce from './setup_once';

(function() {
  let Sidebar = Backbone.View.extend({
    events: {
      'click .sidebar__header-link': 'toggleGroup',
    },

    toggleGroup: function(e) {
      let $group = $(e.target).parents('.sidebar__group');
      $group.toggleClass('sidebar__group--closed sidebar__group--open');
    },
  });

  $.subscribe('sidebar:nesting', function() {
    setupOnce('.sidebar', Sidebar);
  });
})();
