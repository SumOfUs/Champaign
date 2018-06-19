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
    this.checkOverflow();
  },

  checkOverflow() {
    // if the page is too short for the form, make it scroll overflow
    let maxHeight = window.innerHeight - this.topHeight;
    const $title = this.$(`.${this.baseClass}__title-bar`);
    if (this.$el.hasClass('stuck-right') && $title.length) {
      maxHeight -= $title.outerHeight();
    }
    const main = this.$(`.${this.baseClass}__main`);
    const overflow = main[0].scrollHeight > maxHeight ? 'scroll' : 'visible';

    main.css('overflow', overflow);
    main.css('max-height', `${maxHeight}px`);
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
