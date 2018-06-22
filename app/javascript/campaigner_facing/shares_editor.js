// @flow
import $ from 'jquery';
import Backbone from 'backbone';
import _ from 'lodash';
import setupOnce from './setup_once';
import ee from '../shared/pub_sub';
import GlobalEvents from '../shared/global_events';
import Clipboard from 'clipboard';

const SharesEditor = Backbone.View.extend({
  events: {
    'ajax:success form.shares-editor__delete-variant': 'deleteVariant',
    'click .shares-editor__toggle-edit': 'toggleEditor',
    'click .shares-editor__new-type-toggle .btn': 'switchVariantForm',
    'click .shares-editor__view-toggle .btn': 'switchView',
    'ajax:success form.shares-editor__new-form': 'clearFormAndConformView',
  },

  globalEvents: {
    'page:saved': 'updateSummaryRows',
    'page:errors': 'openEditorForErrors',
    'image:success': 'addImageSelectors',
    'image:destroyed': 'pruneImageSelectors',
  },

  initialize: function() {
    this.view = 'summary';
    GlobalEvents.bindEvents(this);
  },

  deleteVariant: function(e) {
    const $target = $(e.target);
    const $summary_row = $target.parents('.shares-editor__summary-row');
    const $stats_row = $summary_row.next('.shares-editor__stats-row');
    const $edit_row = $stats_row.next('.shares-editor__edit-row');
    $summary_row.remove();
    $stats_row.remove();
    $edit_row.remove();
  },

  editRow: function($row) {
    if (!$row.hasClass('shares-editor__stats-row')) {
      $row = $row.next('.shares-editor__stats-row');
    }
    return $row.next('.shares-editor__edit-row');
  },

  toggleEditor: function(e) {
    let $target = this.$(e.target);
    $target = $target.is('tr') ? $target : $target.parents('tr');
    const $btn = $target.find('.shares-editor__toggle-edit');
    this.editRow($target).toggleClass('hidden-closed');
    $btn.text($btn.text() == 'Edit' ? 'Done' : 'Edit');
  },

  openEditor: function($edit_row) {
    const $prev = $edit_row.prev('.shares-editor__summary-row');
    const $btn = $prev.find('.shares-editor__toggle-edit');
    $btn.text('Done');
    $edit_row.removeClass('hidden-closed');
  },

  switchVariantForm: function(e) {
    const $target = this.$(e.target);
    const desired = $target.data('state');
    if (desired) {
      this.$('.shares-editor__new-type-toggle .btn').removeClass('btn-primary');
      $target.addClass('btn-primary');
      this.$('.shares-editor__new-form').addClass('hidden-closed');
      this.$(`.shares-editor__new-form[data-share="${desired}"]`).removeClass(
        'hidden-closed'
      );
    }
  },

  switchView: function(e) {
    const $target = this.$(e.target);
    const desired = $target.data('state');
    if (desired) {
      this.setView(desired);
    }
  },

  setView: function(desired) {
    this.view = desired;
    this.$('.shares-editor__view-toggle .btn').removeClass('btn-primary');
    this.$(`[data-state="${desired}"]`).addClass('btn-primary');
    if (desired === 'summary') {
      this.$('.shares-editor__summary-row').removeClass('hidden-closed');
      this.$('.shares-editor__stats-row').addClass('hidden-closed');
      this.$('.shares-editor__stats-heading').addClass('hidden-closed');
    } else {
      this.$('.shares-editor__summary-row').addClass('hidden-closed');
      this.$('.shares-editor__stats-row').removeClass('hidden-closed');
      this.$('.shares-editor__stats-heading').removeClass('hidden-closed');
    }
  },

  clearFormAndConformView: function(e) {
    $(e.target)
      .find('input[type="text"], textarea')
      .val('');
    this.setView(this.view); // make new rows conform
  },

  openEditorForErrors: function() {
    this.openEditor(this.$('.has-error').parents('.shares-editor__edit-row'));
  },

  updateSummaryRows: function(data) {
    // this only updates existing shares. new ones are appended by
    // code in view/share/shares/create.js.erb, using rails UJS
    $.get(`/api/pages/${data.id}/share-rows`, rows => {
      _.each(rows, row => {
        let $row = $(row.html);
        const $original = $(`#${$row.prop('id')}`);
        if ($original.hasClass('hidden-closed')) {
          $row.addClass('hidden-closed');
        }
        $row = $original.replaceWith($row);
        $row = $(`#${$row.prop('id')}`);
        if (!this.editRow($row).hasClass('hidden-closed')) {
          $row.find('.shares-editor__toggle-edit').text('Done');
        }
      });
    });
  },

  addImageSelectors: function(file, id, html) {
    const newOption = `<option value='${id}'>${file.name}</option>`;
    this.$('.shares-editor__image-selector').append(newOption);
  },

  pruneImageSelectors: function(id) {
    this.$(`option[value="${id}"]`).remove();
  },
});

ee.on('shares:edit', function() {
  setupOnce('.shares-editor', SharesEditor);
});

$(function() {
  new Clipboard('.share-copy-url');

  $('.shares-editor__existing').on(
    'click',
    '.share-copy-url',
    (e: JQueryEventObject) => {
      e.preventDefault();
    }
  );
});
