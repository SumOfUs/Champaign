'use strict';
import Backbone from 'backbone';

$(function() {
  var slugChecker = Backbone.Model.extend({
    url: '/action_kit/check_slug',

    defaults: {
      valid: null,
      slug: '',
    },
  });

  var slugView = Backbone.View.extend({
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
      this.slugChecker.on(
        'change:valid',
        _.bind(this.updateViewWithValid, this)
      );
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
      var valid = this.slugChecker.get('valid');

      this.$submit.removeClass('disabled');

      this.$('.loading').hide();

      this.$('.form-group.slug').removeClass(
        'has-error has-success has-feedback'
      );

      this.$('.form-group.slug .glyphicon').hide();

      if (valid) {
        this.$('.form-group.slug').addClass('has-success has-feedback');
        this.$('.form-group.slug .glyphicon-ok').show();
      } else {
        this.$('.slug-field').show();

        this.$('.form-group.slug').addClass('has-error has-feedback');
        this.$('.form-group.slug .glyphicon-remove').show();
      }
    },

    generateSlug() {
      var slug = getSlug(this.$title.val());
      this.resetFeedback();
      this.$slug.val(slug);
    },

    checkSlugAvailable(e, cb) {
      var slug;

      e.preventDefault();
      this.updateSlug();
      slug = this.$slug.val();

      this.checking = true;

      this.$submit.addClass('disabled');

      this.$('.loading').show();

      this.slugChecker.set('slug', slug);

      this.slugChecker.save().done(() => {
        this.checking = false;
        this.$checkButton
          .text('Check if name is available')
          .removeClass('disabled');

        if (cb) {
          cb.call(this);
        }
      });
    },

    updateSlug() {
      var slug = getSlug(this.$slug.val());
      this.resetFeedback();
      this.$slug.val(slug);
    },

    resetFeedback() {
      this.$feedback.removeClass('has-error has-success has-feedback');
    },

    submit(e) {
      e.preventDefault();

      this.$checkButton.text('Checking...').addClass('disabled');

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

  var initialize = () => {
    new slugView();
  };

  $.subscribe('pages:new', initialize);
});
