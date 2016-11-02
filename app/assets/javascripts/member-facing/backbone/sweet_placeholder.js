const SweetPlaceholder = Backbone.View.extend({

  el: '.sweet-placeholder',

  events: {
    'focus .sweet-placeholder__field': 'focus',
    'blur  .sweet-placeholder__field': 'blur',
    'click .sweet-placeholder__label': 'fauxcus',
    'change select.sweet-placeholder__field': 'decide',
    'input .sweet-placeholder__field': 'decide',
  },

  focus(e) {
    console.log('focus', e);
    var $label = this.rootEl(e.target).find('.sweet-placeholder__label');
    $label.addClass('sweet-placeholder__label--active');
  },

  blur(e) {
    console.log('blur', e);
    var $field = this.rootEl(e.target).find('.sweet-placeholder__field'); 
    var $label = this.rootEl(e.target).find('.sweet-placeholder__label');
    if ($field.is(':focus')) {
      // this.focus(e);
      return;
    }
    $label.removeClass('sweet-placeholder__label--active');
    if($field.val().length === 0) {
      $label.removeClass('sweet-placeholder__label--full');
    } else {
      $label.addClass('sweet-placeholder__label--full');
    }
  },

  fauxcus(e) {
    console.log('fauxcus', e, this.rootEl(e.target));
    console.log(this.rootEl(e.target).find('.sweet-placeholder__field'));
    if (this.rootEl(e.target).find('.selectize').length){
      console.log('come on now', this.$('.selectize')[0]);
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
