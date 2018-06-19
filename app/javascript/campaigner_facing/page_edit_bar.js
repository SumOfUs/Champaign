import ee from '../shared/pub_sub';
import ErrorDisplay from '../shared/show_errors';
import _ from 'lodash';

let PageModel = Backbone.Model.extend({
  urlRoot: '/api/pages',

  initialize: function() {
    this.lastSaved = null;
  },

  // override save to only actually save if it's new data
  save: function(data, callbacks) {
    if (_.isEqual(data, this.lastSaved)) {
      if (typeof callbacks.unchanged === 'function') {
        callbacks.unchanged();
      }
    } else {
      this.lastSaved = data;
      Backbone.Model.prototype.save.call(
        this,
        data,
        _.extend({ patch: true }, callbacks)
      );
    }
  },

  setLastSaved: function(data) {
    this.lastSaved = data;
  },
});

let PageEditBar = Backbone.View.extend({
  el: '.page-edit-bar',

  events: {
    'click .page-edit-bar__save-button': 'save',
    'click .page-edit-bar__error-message': 'findError',
    'change .page-edit-bar__toggle-autosave .onoffswitch__checkbox':
      'toggleAutosave',
  },

  initialize: function() {
    this.outstandingSaveRequest = false;
    this.addStepsToSidebar();
    this.model = new PageModel();
    this.setupAutosave();
    this.$saveBtn = this.$('.page-edit-bar__save-button');
    $('body').scrollspy({ target: '.scrollspy', offset: 150 });
    this.policeHeights();
  },

  addStepsToSidebar: function() {
    const $existing = $('ul.page-edit-bar__step-list li');
    $('.page-edit-step').each((ii, step) => {
      this.addStepToSidebar($(step));
    });
    $existing.remove();
    this.$('ul.page-edit-bar__step-list').append($existing);
  },

  addStepToSidebar: function($step) {
    let $ul = this.$('ul.page-edit-bar__step-list');
    const title = $step
      .find('.page-edit-step__title')[0]
      .childNodes[0].nodeValue.trim();
    const id = $step.attr('id');
    const icon = $step.data('icon') || 'cubes';
    const link_href = $step.data('link-to') ? $step.data('link-to') : `#${id}`;
    const link_target = $step.data('link-to') ? '_blank' : '_self';
    const li = `<li><a href="${link_href}" target="${link_target}"><i class="fa fa-${icon}"></i>${title}</a></li>`;
    $ul.append(li);
  },

  readData: function() {
    let data = {};
    $('form.one-form').each((ii, form) => {
      let $form = $(form);
      let type = $form.data('type') || 'base';
      if (!data.hasOwnProperty(type)) {
        data[type] = {};
      }
      $.extend(data[type], this.serializeForm($form));
    });
    data.id = data.page['page[id]'];
    return data;
  },

  serializeForm: function($form) {
    let data = {};
    _.each($form.serializeArray(), function(pair) {
      // this is to handle form arrays cause their name ends in []
      if (pair.name.endsWith('[]')) {
        let name = pair.name.slice(0, -2);
        if (!data.hasOwnProperty(name)) {
          data[name] = [];
        }
        data[name].push(pair.value);
      } else {
        data[pair.name] = pair.value;
      }
    });
    return data;
  },

  save: function() {
    ee.emit('wysiwyg:submit'); // for summernote + codemirror to update content
    if (!this.outstandingSaveRequest) {
      this.disableSubmit();
      this.model.save(this.readData(), {
        success: this.saved.bind(this),
        error: this.saveFailed.bind(this),
        unchanged: this.enableSubmit.bind(this),
      });
    }
  },

  saved: function(e, data) {
    if (data.refresh) {
      location.reload();
    }
    this.enableSubmit();
    ee.emit('page:saved', data);
    $('.page-edit-bar__save-box').removeClass(
      'page-edit-bar__save-box--has-error'
    );
    $('.page-edit-bar__error-message').text('');
    $('.page-edit-bar__last-saved').text(
      I18n.t('pages.edit.last_saved_at', { time: this.currentTime() })
    );
    this.policeHeights();
  },

  currentTime: function() {
    const now = new Date();
    const minutes = `0${now.getMinutes()}`.slice(-2); // for leading zero
    const seconds = `0${now.getSeconds()}`.slice(-2); // for leading zero
    return `${now.getHours()}:${minutes}:${seconds}`;
  },

  saveFailed: function(e, data) {
    console.error('Save failed with', e, data);
    this.enableSubmit();
    $('.page-edit-bar__save-box').addClass(
      'page-edit-bar__save-box--has-error'
    );
    if (data.status == 422) {
      ErrorDisplay.show(e, data);
      $('.page-edit-bar__error-message').text(I18n.t('pages.edit.user_error'));
      ee.emit('page:errors');
    } else {
      $('.page-edit-bar__error-message').text(
        I18n.t('pages.edit.unknown_error')
      );
    }
    this.policeHeights();
  },

  findError: function() {
    if (
      this.$('.page-edit-bar__save-box').hasClass(
        'page-edit-bar__save-box--has-error'
      )
    ) {
      if ($('.has-error').length > 0) {
        $('html, body').animate(
          {
            scrollTop: $('.has-error')
              .first()
              .offset().top,
          },
          500
        );
      }
    }
  },

  toggleAutosave: function(e) {
    this.autosave = !this.autosave;
    this.$('.page-edit-bar__toggle-autosave')
      .find('.toggle-button')
      .toggleClass('btn-primary');
    if (this.autosave) {
      this.$('.page-edit-bar__btn-holder').addClass(
        'page-edit-bar__btn-holder--hidden'
      );
    } else {
      this.$('.page-edit-bar__btn-holder').removeClass(
        'page-edit-bar__btn-holder--hidden'
      );
    }
    window.setTimeout(() => {
      this.policeHeights();
    }, 200);
  },

  disableSubmit: function() {
    this.outstandingSaveRequest = true;
    this.$saveBtn.text(I18n.t('pages.edit.saving'));
    this.$saveBtn.addClass('disabled');
  },

  enableSubmit: function() {
    this.outstandingSaveRequest = false;
    this.$saveBtn.text(I18n.t('pages.edit.save_work'));
    this.$saveBtn.removeClass('disabled');
  },

  setupAutosave: function() {
    const SAVE_PERIOD = 5000; // milliseconds
    const shouldAutosave =
      this.$('.page-edit-bar__toggle-autosave').data('autosave') == true;
    this.autosave = true;
    this.model.setLastSaved(this.readData());
    if (shouldAutosave != this.autosave) {
      this.toggleAutosave();
    }
    window.setInterval(() => {
      if (this.autosave) {
        this.save();
      } else {
        this.showUnsavedAlert();
      }
    }, SAVE_PERIOD);
  },

  showUnsavedAlert: function() {
    ee.emit('wysiwyg:submit'); // update wysiwyg
    let $lastSaved = $('.page-edit-bar__last-saved');
    const noNotice =
      $lastSaved.find('.page-edit-bar__unsaved-notice').length < 1;
    const unsavedDataExists = !_.isEqual(this.model.lastSaved, this.readData());
    if (unsavedDataExists) {
      if (noNotice) {
        $lastSaved.append(
          `<div class="page-edit-bar__unsaved-notice">${I18n.t(
            'pages.edit.unsaved_changes'
          )}</div>`
        );
      }
    } else {
      $lastSaved.find('.page-edit-bar__unsaved-notice').remove();
    }
  },

  policeHeights: function() {
    if ($(window).width() <= 600) {
      return;
    }
    var height =
      $(window).height() -
      this.$('.page-edit-bar__logo').height() -
      this.$('.page-edit-bar__save-box').height() -
      this.$('.page-edit-bar__btn-holder').outerHeight();
    this.$('.page-edit-bar__step-list').css('height', `${height}px`);
  },
});

export default PageEditBar;
