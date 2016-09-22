const PaymentMethodView = require('./payment-method.view');

class PaymentMethodsView extends Backbone.View {
  constructor(options) {
    super(options);
    _.bindAll(this, 'render');
    this.setElement($('#payment-methods-collection'), true);

    this.collection.bind('reset', this.render);

    this.render();
  }

  render() {
    this.$el.empty();

    this.collection.forEach((model, idx) => {
      // set the `checked` attribute to true in
      // the first element
      const view = new PaymentMethodView({ model });
      model.set('checked', idx === 0);
      this.$el.append(view.render().el);
    });
  }
}

module.exports = PaymentMethodsView;
