// @flow
import $ from 'jquery';
import Backbone from 'backbone';
import ee from '../shared/pub_sub';
import setupOnce from './setup_once';

const Sidebar = Backbone.View.extend({
  events: {
    'click .sidebar__header-link': 'toggleGroup',
  },

  toggleGroup: function(e) {
    const $group = $(e.target).parents('.sidebar__group');
    $group.toggleClass('sidebar__group--closed sidebar__group--open');
  },
});

ee.on('sidebar:nesting', function() {
  setupOnce('.sidebar', Sidebar);
});
