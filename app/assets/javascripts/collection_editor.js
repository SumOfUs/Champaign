// This file handles the behaviour for managing form building.
//
// Dependencies:
//
//   jQuery.ui.sortable: https://jqueryui.com/sortable/
//   - Allows form fields to be dragged and re-oredered
//
//   Twitter's typeahead: http://twitter.github.io/typeahead.js/
//   - Use for autocompleting for setting the field's name value

(function(){
  let CollectionEditor = Backbone.View.extend({

    whitelist: [
      // Permitted fields provided by ActionKit
      "address1",
      "address2",
      "city",
      "country",
      "email",
      "full_name",
      "mobile_phone",
      "name",
      "phone",
      "plus4",
      "postal",
      "prefix",
      "region",
      "state",
      "suffix",
      "zip",

      // Common custom fields used by campaigners
      "customer",
      "employee",
      "shareholder",
      "investor"
    ],

    events: {
      'ajax:success #new_collection_element': 'newElementAdded',
      'ajax:success #change-form-template': 'templateChanged',
      'sortupdate': 'updateSort',
    },

    initialize: function(){
      this.makeSortable();
      this.autoComplete();
      this.$el.on('ajax:success', "a[data-method=delete]", function(){
        $(this).parents('.list-group-item').fadeOut();
      });
    },

    substringMatcher: function(strs) {
      return function findMatches(q, cb) {
        var matches = [];
        var substrRegex = new RegExp(q, 'i');

        // Iterate through the pool of strings and for any string that
        // contains the substring `q`, add it to the `matches` array
        $.each(strs, function(i, str) {
          if (substrRegex.test(str)) {
            matches.push(str);
          }
        });
        cb(matches);
      };
    },

    autoComplete: function(){
      this.$('.typeahead').typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      }, {
        name: 'fields',
        source: this.substringMatcher(this.whitelist)
      });
    },

    makeSortable: function(){
      this.$( ".list-group.sortable" ).sortable();
    },

    updateSort: function( event, ui, a, b ) {
      var ids = ui.item.parent().
        children().
          map(function(i, el){
            return $(el).data('id');
          }).get().join();

      this.$('#form_element_ids').val(ids);
      this.$('form#sort-collection-elements').submit();
    },

    newElementAdded: function(e, resp, c) {
      this.$('.list-group').append(resp);
      this.makeSortable();
    },

    templateChanged: function(e, resp) {
      this.$('.forms-edit').html(resp.html);
      this.makeSortable();

      // Updates the inline form's action URL with the new form ID.
      this.$('#sort-collection-elements, #new_collection_element').each(function(i, el){
        var action = $(el).attr('action').replace(/\d+/, resp.form_id);
        $(el).attr('action', action);
      });
    }
  });

  const configureCollections = function() {
    $('.collection-editor').each(function(ii, el){
      let $el = $(el);
      if( $el.data('js-inited') != true) {
        let editor = new CollectionEditor({ el: $el });
        $el.data('js-inited', true)
      }
    });
  }

  $.subscribe("collection:edit:loaded", configureCollections);
}());

