// @flow
import $ from 'jquery';
import Backbone from 'backbone';
import ee from '../shared/pub_sub';
import GlobalEvents from '../shared/global_events';

const SurveyEditor = Backbone.View.extend({
  el: '.survey',

  events: {
    'sortupdate .survey__forms': 'handleSort',
  },

  globalEvents: {
    'survey:form_added': 'makeSortable',
  },

  initialize(options = {}) {
    this.makeSortable();
    this.id = this.$el.data('plugin-id');
    GlobalEvents.bindEvents(this);
  },

  makeSortable() {
    this.$('.survey__forms').sortable();
  },

  handleSort(e, ui) {
    if (!$(e.target).hasClass('survey__forms')) return;
    let ids = ui.item
      .parent()
      .children()
      .map((i, el) => {
        return this.$(el).data('id');
      })
      .get();
    this.saveFormOrder(ids);
  },

  saveFormOrder(ids) {
    $.ajax(`/plugins/surveys/${this.id}/sort`, {
      method: 'PUT',
      data: { form_ids: ids.join(',') },
    }).done(function() {
      ee.emit('plugin:form:preview:update');
    });
  },
});

export default SurveyEditor;
