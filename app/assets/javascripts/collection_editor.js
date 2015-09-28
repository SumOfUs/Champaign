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
  var initialize = function(){
    makeSortable();
    bindHandlers();
    autoComplete()
  };

  var whitelist = [
    // Permitted fields provided by ActionKit
    "address1",
    "address2",
    "city",
    "country",
    "email",
    "first_name",
    "last_name",
    "middle_name",
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
  ];

  var substringMatcher = function(strs) {
    return function findMatches(q, cb) {
      var matches, substringRegex;

      // An array that will be populated with substring matches
      matches = [];

      // Regex used to determine if a string contains the substring `q`
      substrRegex = new RegExp(q, 'i');

      // Iterate through the pool of strings and for any string that
      // contains the substring `q`, add it to the `matches` array
      $.each(strs, function(i, str) {
        if (substrRegex.test(str)) {
          matches.push(str);
        }
      });

      cb(matches);
    };
  };

  var autoComplete = function(){
    $('.typeahead').typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    }, {
      name: 'fields',
      source: substringMatcher(whitelist)
    });
  };

  var makeSortable = function(){
    $( ".list-group.sortable" ).sortable();
  };

  var updateSort = function( event, ui, a, b ) {
    var ids = ui.item.parent().
      children().
        map(function(i, el){
          return $(el).data('id');
        }).get().join();

    $('#form_element_ids').val(ids);
    $('form#sort-collection-elements').submit();
  };

  var bindHandlers = function(){
    $('.collection-editor #new_collection_element').on('ajax:success', function(e, resp, c){
      $('.list-group').append(resp);
      makeSortable();
    });

    $('.collection-editor').on('ajax:success', "a[data-method=delete]", function(){
      $(this).parents('.list-group-item').fadeOut();
    });

    $( ".collection-editor" ).on( "sortupdate", updateSort );

    $('#change-form-template').on('ajax:success', function(e, resp) {
      $('.forms-edit').html(resp.html);
      makeSortable();

      // Updates the inline form's action URL with the new form ID.
      $('#sort-collection-elements, #new_collection_element').each(function(i, el){
        var action = $(el).attr('action').replace(/\d+/, resp.form_id);
        $(el).attr('action', action);
      });
    });
  };

  $.subscribe("collection:edit:loaded", initialize);
}());

