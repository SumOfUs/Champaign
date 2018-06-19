// @flow
import $ from 'jquery';
import Backbone from 'backbone';

const OverlayToggle = Backbone.View.extend({
  el: '.overlay-toggle',

  events: {
    'click .overlay-toggle__close-button': 'hide',
  },

  initialize() {
    // we bind this event globally because the button to open the
    // overlay probably isn't inside the overlay
    $('.overlay-toggle__open-button').on('click', this.reveal.bind(this));
  },

  hide() {
    const el = $('.partial--fundraiser');
    if (el.length) {
      el
        .find('.section--header, .section--footer, .center-content__big-column')
        .show();
    }
    this.$('.overlay-toggle__mobile-view')
      .addClass('overlay-toggle__mobile-view--closed')
      .removeClass('overlay-toggle__mobile-view--open');
    // hide header, cover-photo
    $('.center-content').removeClass('overlay-visible');
  },

  reveal() {
    $('.center-content').addClass('overlay-visible');
    this.$('.overlay-toggle__mobile-view')
      .removeClass('overlay-toggle__mobile-view--closed')
      .addClass('overlay-toggle__mobile-view--open');
    const el = $('.partial--fundraiser');
    if (el.length) {
      setTimeout(() => {
        el
          .find(
            '.section--header, .section--footer, .center-content__big-column'
          )
          .hide();
      }, 500);
    }
  },
});

export default OverlayToggle;
