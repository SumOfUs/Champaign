const StickyMethods = {

  initializeSticky: function() {
    this.isSticky = false;
    this.questionSticky();

    // can't use events hash cause scoped to window
    $(window).on('resize', () => this.questionSticky());
  },

  isMobile: function() {
    return $('.mobile-indicator').is(':visible');
  },

  makeSticky: function() {
    if(!this.isSticky) {
      this.$el.sticky({topSpacing:0});
      if (this.$el.hasClass('fundraiser-bar')) {
        this.$el.parent('.sticky-wrapper').addClass('fundraiser');
      } else if (this.$el.hasClass('action-bar')) {
        this.$el.parent('.sticky-wrapper').addClass('action');
      }
      this.isSticky = true;
    }
  },

  unmakeSticky: function() {
    if(this.isSticky) {
      this.$el.unstick();
      this.isSticky = false;
    }
  },

  questionSticky: function() {
    if(this.isMobile()) {
      this.unmakeSticky();
    } else {
      this.makeSticky();
    }
  },

};

module.exports = StickyMethods;
