const StickyMethods = {

  initializeSticky() {
    this.isSticky = false;
    this.questionSticky();

    // can't use events hash cause scoped to window
    $(window).on('resize', () => this.questionSticky());
  },

  isMobile() {
    return $('.mobile-indicator').is(':visible');
  },

  makeSticky() {
    if(!this.isSticky) {
      this.$el.sticky({topSpacing:0});
      if (this.$el.hasClass('fundraiser-bar')) {
        this.$el.parent('.sticky-wrapper').addClass('fundraiser');
      } else if (this.$el.hasClass('petition-bar')) {
        this.$el.parent('.sticky-wrapper').addClass('petition');
      }
      this.isSticky = true;
    }
  },

  unmakeSticky() {
    if(this.isSticky) {
      this.$el.unstick();
      this.isSticky = false;
    }
  },

  questionSticky() {
    if(this.isMobile() || this.$el.hasClass('stuck-right')) {
      this.unmakeSticky();
    } else {
      this.makeSticky();
    }
  },

};

module.exports = StickyMethods;
