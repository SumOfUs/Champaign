const MobileCheck = {
  el: '.mobile-indicator',

  isMobile() {
    return $(this.el).is(':visible');
  },
};

export default MobileCheck;
