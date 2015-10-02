"use strict";

() => {
  var slugChecker = Backbone.Model.extend({
      url: '/action_kit/check_slug',

      defaults: {
        valid: null,
        slug: ''
      }
  });

  var slugView = Backbone.View.extend({
    el: '#new_page',

    initialize() {
      this.slugChecker = new slugChecker();
      this.slugChecker.on("change:valid", _.bind(this.updateViewWithValid, this));
      this.$title = this.$el.find('#page_title');
      this.$slug  = this.$el.find('#page_slug');
      this.$feedback = this.$el.find('.form-group.slug');
      this.$checkButton = this.$el.find('#check_slug_available');
      this.checking = false;
    },

    updateViewWithValid() {
      var valid = this.slugChecker.get('valid');

      this.$el.find('.form-group.slug').
        removeClass('has-error has-success has-feedback');

      this.$el.find('.form-group.slug .glyphicon').hide();

      if(valid) {
        this.$el.find('.form-group.slug').addClass('has-success has-feedback');
        this.$el.find('.form-group.slug .glyphicon-ok').show();
      } else {
        this.$el.find('.form-group.slug').addClass('has-error has-feedback');
        this.$el.find('.form-group.slug .glyphicon-remove').show();
      }
    },

    generateSlug() {
      var slug = getSlug( this.$title.val() );
      this.resetFeedback();
      this.$slug.val( slug );
    },

    checkSlugAvailable(e, cb) {
      var slug;

      e.preventDefault();
      this.updateSlug();
      slug = this.$slug.val();

      this.checking = true;

      this.$checkButton.
        text('Checking...').
        addClass('disabled');

      this.slugChecker.set('slug', slug);

      this.slugChecker.save().done( () => {
        this.checking = false;
        this.$checkButton.
          text('Check if name is available').
          removeClass('disabled');

        if(cb) {
          cb.call(this);
        }
      });
    },

    updateSlug() {
      var slug = getSlug( this.$slug.val() );
      this.resetFeedback();
      this.$slug.val( slug );
    },

    resetFeedback() {
      this.$feedback.
        removeClass('has-error has-success has-feedback');
    },

    submit(e) {
      e.preventDefault();
      if( !this.slugChecker.get('valid') ) {

        this.checkSlugAvailable(e, () => {
          if(this.slugChecker.get('valid')){
            this.$el.unbind();
            this.$el.submit();
          }
        });
      } else {
        this.$el.unbind();
        this.$el.submit();
      }
    },

    events: {
      'keyup #page_title' : 'generateSlug',
      'keyup #page_slug'  : 'resetFeedback',
      'click #check_slug_available' : 'checkSlugAvailable',
      'submit' : 'submit'
    }
  });

  var initialize = () => {
    new slugView();
  };

  $.subscribe("pages:new", initialize);
}();


() => {
  var pageStatus = Backbone.Model.extend({
    initialize(id) {
      this.id = id;
      this.url = `/action_kit/check_petition_page_status?id=${id}`
    }
  });

  var page = Backbone.Model.extend({

    initialize(id) {
      this.url = `/action_kit/create_petition_page?id=${id}`;
    }
  });


  var petitionPageView = Backbone.View.extend({
    initialize(id) {
      this.pageId = id;
      this.pageStatus = new pageStatus(id);
      this.checkStatus();
    },

    checkStatus() {
      this.pageStatus.fetch().done( () => {
        if(this.pageStatus.get('status') == 'pending') {
          new page(this.pageId).save();
          //window.setTimeout( _.bind(this.checkStatus, this), 3000);
        }
      });
    }
  });

  var initialize = (e, page_id) => {
    console.log(page_id);
    new petitionPageView(page_id);
  };

  $.subscribe("pages:edit", initialize);
}();

