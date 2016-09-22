class PaymentMethodItem extends Backbone.View {
  constructor(options) {
    super({
      id: `payment-method-${options.model.get('id')}`,
      model: options.model,
      tagName: 'div',
      className: 'form__group payment-method-item',
    });

    _.bindAll(this, 'render');
    this.template = _.template($('#payment-method-item-template').html());
    this.model.bind('change', this.render);
  }

  render() {
    this.$el.html(this.template(this.model.attributes));
    return this;
  }
}

module.exports = PaymentMethodItem;
