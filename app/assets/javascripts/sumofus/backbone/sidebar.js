const MobileCheck = require('sumofus/backbone/mobile_check');

const Sidebar = Backbone.View.extend({

  el: '.petition-bar',

  initialize(options = {}) {
    this.petitionTextMinHeight = options.petitionTextMinHeight || 120; // pixels
    this.policeHeights();
    if (!MobileCheck.isMobile()) {
      $(window).on('resize', () => this.policeHeights());
    }
  },

  isSticky: function() {
    return this.$el.parent().hasClass('sticky-wrapper');
  },

  policeHeights: function() {
    if (MobileCheck.isMobile()) {
      return;
    }
    console.log('policing heights', this.isSticky());

    // move the blurb up into the correct position
    let topHeight = this.$('.petition-bar__top').outerHeight();
    if (this.isSticky()){
      this.$el.parent('.sticky-wrapper').css('top', `-${topHeight}px`);
      this.$el.css('top', 0);
    } else if(!this.$el.hasClass('stuck-right')){
      this.$el.css('top', `-${topHeight}px`);
    }

    // make sure the title is in the right place if it wraps
    const $title = $('.petition-bar__title-bar');
    $title.css('top', `-${$title.outerHeight()}px`);

    // if the page is too short for the form, make it scroll overflow
    let maxHeight = window.innerHeight - topHeight;
    if(this.$el.hasClass('stuck-right')){
      maxHeight -= $title.outerHeight();
    }
    const overflow = (this.$('.petition-bar__main')[0].scrollHeight > maxHeight) ? 'scroll' : 'visible'
    this.$('.petition-bar__main').css('overflow', overflow);
    this.$('.petition-bar__main').css('max-height', `${maxHeight}px`);
  },

});

module.exports = Sidebar;
