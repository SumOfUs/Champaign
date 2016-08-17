const ActionCounter = Backbone.View.extend({

  el: '.action-counter',

  initialize(options={}) {
    if ((typeof options.actionSource) === (typeof "") && options.actionSource.length) {
      this.socket = io(options.actionSource);
      this.socket.on('actions', this.handleMessage.bind(this));
      this.actionCount = this.parseActionCount();
      this.slugs = options.slugs || [];
    }
  },

  handleMessage(data) {
    let msg = JSON.parse(data);

    if (this.slugs.length === 0) {
      this.incrementCount();
    } else if (this.slugs.indexOf(msg.slug) > -1) {
      this.incrementCount();
    }
  },

  incrementCount() {
    this.actionCount += 1;
    this.$el.text(this.numberWithCommas(this.actionCount));
  },

  parseActionCount(){
    let val = parseInt(this.$el.first().text().replace(/[^0-9]/g, ''));
    return isNaN(val) ? 0 : val;
  },

  // from http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
  numberWithCommas(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

});

module.exports = ActionCounter;
