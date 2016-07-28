const SimpleCarousel = Backbone.View.extend({

  el: '.simple-carousel',
  MS_TO_LEAVE_OPEN: 8000,

  events: {
    'click .simple-carousel__right': 'moveRight',
    'click .simple-carousel__left': 'moveLeft',
  },

  initialize(options={}) {
    this.content = options.content;
    console.log(this.content);
    this.currentIdx = 0;
    this.showCurrent();
    window.setInterval(this.cycle.bind(this), 1000);
  },

  cycle() {
    if (Date.now() - this.lastMoved >= this.MS_TO_LEAVE_OPEN) {
      this.moveRight();
    }
  },

  moveRight() {
    this.currentIdx += 1;
    this.showCurrent();
  },

  moveLeft() {
    this.currentIdx += 1;
    this.showCurrent();
  },

  showCurrent() {
    this.policeIdx();
    console.log(this.currentIdx);
    console.log(this.content[this.currentIdx]);
    this.$('.simple-carousel__text').text(this.content[this.currentIdx].text);
    this.$('.simple-carousel__attribution').text(this.content[this.currentIdx].attribution);
    this.lastMoved = Date.now();
  },

  policeIdx() {
    if (this.currentIdx >= this.content.length) {
      this.currentIdx = 0;
    } else if (this.currentIdx < 0) {
      this.currentIdx = this.content.length - 1;
    }
  },

});

module.exports = SimpleCarousel;
