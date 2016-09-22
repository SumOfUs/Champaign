const PaymentMethodView = require('./payment-method.view');

class PaymentMethodsView extends Backbone.View {
  constructor(options) {
    super({
      collection: options.collection,
      el: '#one-click-form',
      className: 'form',
    });

    _.bindAll(this, 'render');

    this.template = _.template($('#payment-method-collection-template').html());
    this.itemsContainer = '#payment-methods-collection';

    this.collection.bind('reset', this.render);

    this.render();
  }

  render() {
    if (!this.collection.length) {
      return this.$el.empty();
    }

    this.$el.html(this.template());

    const $itemsContainer = this.$el.find(this.itemsContainer);

    this.collection.forEach((model, idx) => {
      const view = new PaymentMethodView({ model });
      model.set('checked', idx === 0);
      $itemsContainer.append(view.render().el);
    });

    return this;
  }
}

module.exports = PaymentMethodsView;
