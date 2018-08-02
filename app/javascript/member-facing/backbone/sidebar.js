// @flow
import $ from 'jquery';
import Backbone from 'backbone';
import GlobalEvents from '../../shared/global_events';
import MobileCheck from './mobile_check';

const Sidebar = Backbone.View.extend({
  el: '.sidebar',

  globalEvents: {
    'sidebar:height_change': 'policeHeights',
    'fundraiser:change_step': 'policeHeights',
  },

  initialize(options = {}) {
    this.petitionTextMinHeight = options.petitionTextMinHeight || 120; // pixels
    this.baseClass = options.baseClass;
    if (!MobileCheck.isMobile()) {
      $(window).on('resize', () => this.policeHeights());
    }
    GlobalEvents.bindEvents(this);
    this.policeHeights();
    window.setTimeout(this.policeHeights.bind(this), 200); // give sticky time to init
  },

  isSticky: function() {
    return this.$el.parent().hasClass('sticky-wrapper');
  },

  policeHeights: function() {
    if (MobileCheck.isMobile()) {
      return;
    }
    this.positionBarTop();
    this.positionBarTitle();
  },

  positionBarTop() {
    // move the blurb up into the correct position
    this.topHeight = this.$(`.${this.baseClass}__top`).outerHeight();
    if (this.isSticky()) {
      this.$el.parent('.sticky-wrapper').css('top', `-${this.topHeight}px`);
      this.$el.css('top', 0);
    } else if (!this.$el.hasClass('stuck-right')) {
      this.$el.css('top', `-${this.topHeight}px`);
    }
  },

  positionBarTitle() {
    // make sure the title is in the right place if it wraps
    const $title = $(`.${this.baseClass}__title-bar`);
    if ($title.length) {
      $title.css('top', `-${$title.outerHeight()}px`);
    }
  },
});

export default Sidebar;
