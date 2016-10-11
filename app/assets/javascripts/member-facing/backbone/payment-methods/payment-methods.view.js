const PaymentMethodView = require('./payment-method.view');

class PaymentMethodsView extends Backbone.View {
  constructor(options) {
    super({
      collection: options.collection,
      el: '#one-click-form',
      className: 'form',
    });

    _.bindAll(this, 'render');

    this.loadTemplate();
    this.itemsContainer = '#payment-methods-collection';

    this.collection.bind('reset', this.render);

    this.render();
  }

  loadTemplate() {
    if (this.collection.length === 1) {
      var templateSelector = '#payment-method-single-template'
    } else {
      var templateSelector = '#payment-method-collection-template'
    }
    this.template = _.template($(templateSelector).html());
  }

  render() {
    if (!this.collection.length) {
      return this.$el.empty();
    }

    if (this.collection.length === 1) {
      this.$el.html(this.template(this.collection.models[0].attributes));  
    } else {
      this.$el.html(this.template());
    }

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
