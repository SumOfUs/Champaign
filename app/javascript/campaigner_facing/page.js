'use strict';
import { Model, View } from 'backbone';
import ee from '../shared/pub_sub';

const slugChecker = Model.extend({
  url: '/action_kit/check_slug',

  defaults: {
    valid: null,
    slug: '',
  },
});

const slugView = View.extend({
  el: '#new_page',

  events: {
    'keyup #page_title': 'generateSlug',
    'change #page_title': 'generateSlug',
    'keyup #page_slug': 'resetFeedback',
    'click #check_slug_available': 'checkSlugAvailable',
    submit: 'submit',
  },

  initialize() {
    this.slugChecker = new slugChecker();
    this.slugChecker.on('change:valid', _.bind(this.updateViewWithValid, this));
    this.cacheDomElements();
    this.checking = false;
  },

  cacheDomElements() {
    this.$title = this.$('#page_title');
    this.$slug = this.$('#page_slug');
    this.$feedback = this.$('.form-group.slug');
    this.$checkButton = this.$('#check_slug_available');
    this.$submit = this.$('.submit-new-page');
  },

  updateViewWithValid() {
    const valid = this.slugChecker.get('valid');

    this.enableButton(this.$submit);

    this.$('.loading').hide();

    this.$('.form-group.slug').removeClass(
      'has-error has-success has-feedback'
    );

    this.$('.form-group.slug .glyphicon').hide();

    console.log('valid is', valid);
    if (valid) {
      this.$('.form-group.slug').addClass('has-success has-feedback');
      this.$('.form-group.slug .glyphicon-ok').show();
    } else {
      this.$('.slug-field').show();
      console.log(this.$('.form-group.slug'));

      this.$('.form-group.slug').addClass('has-error has-feedback');
      this.$('.form-group.slug .glyphicon-remove').show();
    }
  },

  generateSlug() {
    const slug = getSlug(this.$title.val());
    this.resetFeedback();
    this.$slug.val(slug);
  },

  checkSlugAvailable(e, cb) {
    let slug;

    e.preventDefault();
    this.updateSlug();
    slug = this.$slug.val();

    this.checking = true;

    this.disableButton(this.$submit);

    this.$('.loading').show();

    this.slugChecker.set('slug', slug);

    this.slugChecker.save().done(() => {
      this.checking = false;
      this.enableButton(this.$checkButton.text('Check if name is available'));

      if (cb) {
        cb.call(this);
      }
    });
  },

  updateSlug() {
    const slug = getSlug(this.$slug.val());
    this.resetFeedback();
    this.$slug.val(slug);
  },

  resetFeedback() {
    this.$feedback.removeClass('has-error has-success has-feedback');
  },

  disableButton($btn) {
    $btn.prop('disabled', true);
    $btn.addClass('disabled');
  },

  enableButton($btn) {
    $btn.prop('disabled', false);
    $btn.removeClass('disabled');
  },

  submit(e) {
    e.preventDefault();

    this.disableButton(this.$checkButton.text('Checking...'));

    if (!this.slugChecker.get('valid')) {
      this.checkSlugAvailable(e, () => {
        if (this.slugChecker.get('valid')) {
          this.$el.unbind();
          this.$el.submit();
        }
      });
    } else {
      this.$el.unbind();
      this.$el.submit();
    }
  },
});

const initialize = () => {
  new slugView();
};

ee.on('pages:new', initialize);
