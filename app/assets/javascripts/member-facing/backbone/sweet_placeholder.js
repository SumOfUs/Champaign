const SweetPlaceholder = Backbone.View.extend({

  el: '.sweet-placeholder',

  events: {
    'focus .sweet-placeholder__field': 'focus',
    'blur  .sweet-placeholder__field': 'blur',
    'click .sweet-placeholder__label': 'fauxcus',
    'change .sweet-placeholder__field': 'decide',
    'input .sweet-placeholder__field': 'decide',
  },

  initialize(els=null) {
    const $els = els || this.$el.find('.sweet-placeholder__field');

    $els.each((el) => {
      this.decide({target: el});
    });
  },

  focus(e) {
    let $label = this.rootEl(e.target).find('.sweet-placeholder__label');
    $label.addClass('sweet-placeholder__label--active');
  },

  blur(e) {
    let $field = this.rootEl(e.target).find('.sweet-placeholder__field');
    let $label = this.rootEl(e.target).find('.sweet-placeholder__label');
    if ($field.is(':focus')) return;
    $label.removeClass('sweet-placeholder__label--active');
    let empty = (!$field.val() || $field.val().length === 0);
    $label.toggleClass('sweet-placeholder__label--full', !empty);
  },

  fauxcus(e) {
    if (this.rootEl(e.target).find('.selectize').length){
      this.rootEl(e.target).find('.sweet-placeholder__field input').focus();
      this.rootEl(e.target).find('.selectize')[0].selectize.open();
    } else {
      this.rootEl(e.target).find('.sweet-placeholder__field').focus();
    }
  },

  decide(e) {
    let $field = this.rootEl(e.target).find('.sweet-placeholder__field');
    if ($field.is(':focus') || $field.find('input').is(':focus')) {
      this.focus(e);
    } else {
      this.blur(e);
    }
  },

  rootEl(target) {
    return this.$(target).parents('.sweet-placeholder');
  },
});

module.exports = SweetPlaceholder;
