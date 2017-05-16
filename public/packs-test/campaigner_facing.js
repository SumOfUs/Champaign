/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/packs-test/";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 524);
/******/ })
/************************************************************************/
/******/ ({

/***/ 113:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
// This file adds error messages inline to forms.
// For it to work properly, you need to pass data from the controller like:
//   format.json { render json: {errors: link.errors, name: 'link'}, status: :unprocessable_entity }
// The name field is for if the form element names are prefixed, eg 'link[title]'

exports.default = {
  show: function show(e, data) {
    if (!e || !data || !data.responseText || !data.getResponseHeader('Content-Type').match(/json/i) || data.status != 422) {
      return; // no reason to try if we dont have what we need
    }

    // use the relevant form if the event was a form submission.
    // otherwise, search in all the forms on the page.
    var $form = $(e.target) && $(e.target).length ? $(e.target) : $('form');
    var response = $.parseJSON(data.responseText);
    ErrorDisplay.clearErrors($form);
    $.each(response.errors, function (f, m) {
      ErrorDisplay.showError(f, m, $form, response);
    });
  },
  clearErrors: function clearErrors($form) {
    $form.find('.has-error').removeClass('has-error');
    $form.find('.error-msg').remove();
  },
  showError: function showError(field_name, msgs, $form, response) {
    var $field = ErrorDisplay.findField(field_name, $form, response);
    $field.addClass('has-error').parent().addClass('has-error');
    $field.parent().append(ErrorDisplay.errorMsg(field_name, msgs));
    $field.on('change', function (e) {
      ErrorDisplay.hideError(e);
    });
  },
  errorMsg: function errorMsg(field_name, msgs) {
    var msg = typeof msgs === 'string' ? msgs : msgs[0];
    var prefix = window.I18n ? I18n.t('errors.this_field') : 'The field';
    return '<div class=\'error-msg\'>' + prefix + ' ' + msg + '</div>';
  },
  hideError: function hideError(e) {
    $(e.target).removeClass('has-error').parent().removeClass('has-error');
    $(e.target).siblings('.error-msg').remove();
    $(e.target).parent('.error-msg').remove();
  },
  findField: function findField(field_name, $form, response) {
    if (response.name) {
      field_name = [response.name, '[', field_name, ']'].join('');
    }
    var $field = $form.find('[name="' + field_name + '"]');
    if (!$field.length) {
      $field = $form.find(':submit').prev();
    } else if ($field.attr('type') === 'radio' && $field.parents('.radio-container').length) {
      return $field.parents('.radio-container');
    }
    return $field;
  }
};

/***/ }),

/***/ 115:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _jquery = __webpack_require__(36);

var _jquery2 = _interopRequireDefault(_jquery);

var _lodash = __webpack_require__(22);

var _lodash2 = _interopRequireDefault(_lodash);

var _backbone = __webpack_require__(78);

var _backbone2 = _interopRequireDefault(_backbone);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

exports.default = {
  bindEvents: function bindEvents(view) {
    var events = view.globalEvents;
    if (!events || !_lodash2.default.isObject(events)) return;
    for (var eventName in events) {
      var methodName = events[eventName];
      var method = view[methodName];
      if (method) {
        _backbone2.default.on(eventName, method, view);
        _jquery2.default.subscribe(eventName, method.bind(view));
      }
    }
  }
}; // allow backbone views to use a hash to declaratively
// bind their methods to events called through
// $.publish or Backbone.trigger

/***/ }),

/***/ 22:
/***/ (function(module, exports) {

module.exports = window._;

/***/ }),

/***/ 276:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
function setupOnce(selector, viewClass) {
  $(selector).each(function (ii, el) {
    var $el = $(el);
    if ($el.data('js-inited') != true) {
      var toggle = new viewClass({ el: $el });
      $el.data('js-inited', true);
    }
  });
}

exports.default = setupOnce;

/***/ }),

/***/ 315:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


(function ($) {
  var o = $({});

  $.subscribe = function () {
    o.on.apply(o, arguments);
  };

  $.unsubscribe = function () {
    o.off.apply(o, arguments);
  };

  $.publish = function () {
    o.trigger.apply(o, arguments);
  };
})(jQuery);

/***/ }),

/***/ 36:
/***/ (function(module, exports) {

module.exports = window.$;

/***/ }),

/***/ 438:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _setup_once = __webpack_require__(276);

var _setup_once2 = _interopRequireDefault(_setup_once);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

$(function () {
  var ActionsEditor = Backbone.View.extend({
    events: {
      'click .action-publisher .btn': 'handleClick',
      'ajax:success form.shares-editor__new-form': 'clearFormAndConformView'
    },

    initialize: function initialize() {
      this.pageId = this.$el.data('page-id');
    },
    updateButtons: function updateButtons($publisher, desired) {
      $publisher.find('.btn-primary').removeClass('btn-primary');
      $publisher.find('[data-state="' + desired + '"]').addClass('btn-primary');
    },
    handleClick: function handleClick(e) {
      var $target = $(e.target);
      var $publisher = $target.parents('.action-publisher');
      var current = $publisher.find('.btn-primary').data('state');
      var desired = $target.data('state');
      this.updateAction($publisher, desired, current);
    },
    updateAction: function updateAction($publisher, desired, last) {
      var _this = this;

      this.updateButtons($publisher, desired);
      $.ajax('/api/pages/' + this.pageId + '/actions/' + $publisher.data('id'), {
        method: 'PUT',
        data: { publish_status: desired }
      }).fail(function () {
        _this.updateButtons($publisher, last);
      });
    }
  });

  $.subscribe('actions:edit', function () {
    (0, _setup_once2.default)('.actions-editor', ActionsEditor);
  });
});

/***/ }),

/***/ 439:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _show_errors = __webpack_require__(113);

var _show_errors2 = _interopRequireDefault(_show_errors);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

$(function () {
  var handleStart = function handleStart(e, i) {
    var button = $(e.target).find('.xhr-feedback');

    $(e.target).find('.xhr-feedback-saving').remove();

    button.prop('disabled', true);

    var feedback = $('<span />').addClass('label label-success xhr-feedback-saving').text('Saving...');

    button.after(feedback);
  };

  var enableButton = function enableButton(e) {
    var button = $(e.target).find('.xhr-feedback');
    button.prop('disabled', false);
  };

  var handleError = function handleError(e, data) {
    enableButton(e);
    var feedback = $('.xhr-feedback-saving').removeClass('label-success').addClass('label-danger').text('Save failed.');
    _show_errors2.default.show(e, data);
  };

  var handleSuccess = function handleSuccess(e) {
    enableButton(e);
    var feedback = $('.xhr-feedback-saving').text('Saved!');

    window.setTimeout(function () {
      feedback.fadeOut();
    }, 1000);
  };

  $('body').on('ajax:beforeSend', handleStart);
  $('body').on('ajax:success', handleSuccess);
  $('body').on('ajax:error', handleError);
});

/***/ }),

/***/ 440:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () {
  function defineProperties(target, props) {
    for (var i = 0; i < props.length; i++) {
      var descriptor = props[i];descriptor.enumerable = descriptor.enumerable || false;descriptor.configurable = true;if ("value" in descriptor) descriptor.writable = true;Object.defineProperty(target, descriptor.key, descriptor);
    }
  }return function (Constructor, protoProps, staticProps) {
    if (protoProps) defineProperties(Constructor.prototype, protoProps);if (staticProps) defineProperties(Constructor, staticProps);return Constructor;
  };
}();

function _classCallCheck(instance, Constructor) {
  if (!(instance instanceof Constructor)) {
    throw new TypeError("Cannot call a class as a function");
  }
}

var Y_AXIS_LABEL_LIMIT = 20;

var AnalyticsDashboard = function () {
  _createClass(AnalyticsDashboard, null, [{
    key: 'yAxisLabelLimit',
    get: function get() {
      return Y_AXIS_LABEL_LIMIT;
    }
  }]);

  function AnalyticsDashboard() {
    _classCallCheck(this, AnalyticsDashboard);

    this.barPadding = 1;
    this.bottomMargin = 100;
    this.margins = { bottom: 30 };
    this.xAxis = true;
    this.labels = true;
  }

  _createClass(AnalyticsDashboard, [{
    key: 'render',
    value: function render() {
      this.svg.attr('width', this.width).attr('height', this.height + this.margins.bottom);

      this.setYScale(this.data);
      this.draw();

      if (this.labels) {
        this.drawLabels();
      }

      if (this.xAxis) {
        this.drawAxis();
      }
    }
  }, {
    key: 'update',
    value: function update() {
      var _this = this;

      this.setYScale(this.data);

      this.svg.selectAll('.bar').data(this.data).transition().duration(750).attr('height', function (d) {
        return _this.scale(d.value);
      }).attr('y', function (d) {
        return _this.height - _this.scale(d.value);
      });

      this.drawLabels();

      this.svg.selectAll('.label').data(this.data).transition().duration(1000).text(function (d) {
        return d.value;
      }).attr('y', this.setYForLabel.bind(this)).attr('fill', this.setFillForLabel.bind(this));
    }
  }, {
    key: 'setYForLabel',
    value: function setYForLabel(d) {
      var scaled = this.scale(d.value),
          y = this.height - scaled + 15;

      if (scaled < AnalyticsDashboard.yAxisLabelLimit) {
        y -= AnalyticsDashboard.yAxisLabelLimit;
      }

      return y;
    }
  }, {
    key: 'setFillForLabel',
    value: function setFillForLabel(d) {
      return this.scale(d.value) < 20 ? '#333' : '#fff';
    }
  }, {
    key: 'draw',
    value: function draw() {
      var _this2 = this;

      this.svg.selectAll('.bar').data(this.data).enter().append('rect').attr('width', this.width / this.data.length - this.barPadding).attr('fill', this.fill).attr('class', 'bar').attr('height', function (d) {
        return _this2.scale(d.value);
      }).attr('y', function (d) {
        return _this2.height - _this2.scale(d.value);
      }).attr('x', function (d, i) {
        return i * (_this2.width / _this2.data.length);
      });
    }
  }, {
    key: 'drawLabels',
    value: function drawLabels() {
      var _this3 = this;

      this.svg.selectAll('text').data(this.data).enter().append('text').text(function (d) {
        return d.value;
      }).attr('x', function (d, i) {
        return i * (_this3.width / _this3.data.length) + (_this3.width / _this3.data.length - _this3.barPadding) / 2;
      }).attr('y', this.setYForLabel.bind(this)).attr('class', 'label').attr('text-anchor', 'middle').attr('font-family', 'sans-serif').attr('font-size', '11px').attr('fill', this.setFillForLabel.bind(this));
    }
  }, {
    key: 'drawAxis',
    value: function drawAxis() {
      var _this4 = this;

      var xScale = d3.scale.ordinal().domain(this.data.map(function (d, i) {
        return moment(d.date).format(_this4.axisDateFormat);
      })).rangeBands([0, this.width]);

      var xAxis = d3.svg.axis().scale(xScale).orient('bottom');

      this.svg.append('g').attr('class', 'x axis').attr('transform', 'translate(0, ' + this.height + ')').call(xAxis);
    }
  }, {
    key: 'setYScale',
    value: function setYScale(dataset) {
      this.scale = d3.scale.linear().domain([0, d3.max(dataset, function (d) {
        return d.value;
      })]).range([0, this.height]);
    }
  }]);

  return AnalyticsDashboard;
}();

var Conductor = function () {
  function Conductor(id, chart) {
    _classCallCheck(this, Conductor);

    this.id = id;
    this.chart = chart;
    this.$totalAll = $('.total-actions-all');
    this.$totalNew = $('.total-actions-new');

    $('button#refresh-data').on('click', this.refreshData.bind(this));
  }

  _createClass(Conductor, [{
    key: 'getData',
    value: function getData(cb) {
      var _this5 = this;

      d3.json('/api/pages/' + this.id + '/analytics.json', function (json) {
        if (cb) {
          cb(json);
          _this5.setCounters(json.totals);
        }
      });
    }
  }, {
    key: 'setCounters',
    value: function setCounters(totals) {
      this.$totalAll.html(totals.all_total);
      this.$totalNew.html(totals.new_total);
    }
  }, {
    key: 'refreshData',
    value: function refreshData() {
      var _this6 = this;

      this.getData(function (data) {
        _this6.chart.data = data.hours;
        _this6.chart.update();
      });
    }
  }]);

  return Conductor;
}();

var createMiniChart = function createMiniChart(className, data) {
  var svg = d3.select('#analytics-dashboard .' + className + ' .chart');

  var chart = new AnalyticsDashboard();
  chart.width = 360;
  chart.height = 70;
  chart.fill = 'rgba(51,51,51,0.3)';
  chart.data = data;
  chart.xAxis = false;
  chart.labels = false;
  chart.svg = svg;
  return chart;
};

exports.default = {
  makeDashboard: function makeDashboard(pageId) {
    var shortChartSVG = d3.select('#analytics-dashboard .short-view .chart'),
        chart = new AnalyticsDashboard(),
        d = new Conductor(pageId, chart);

    d.getData(function (data) {
      chart.width = 495;
      chart.height = 280;
      chart.data = data.hours;
      chart.fill = 'rgba(51,51,51,1)';
      chart.svg = shortChartSVG;
      chart.axisDateFormat = 'HH a';
      chart.render();

      createMiniChart('mini-total', data.days_total.reverse()).render();

      createMiniChart('mini-new', data.days_new.reverse()).render();
    });
  }
};

/***/ }),

/***/ 441:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _setup_once = __webpack_require__(276);

var _setup_once2 = _interopRequireDefault(_setup_once);

var _show_errors = __webpack_require__(113);

var _show_errors2 = _interopRequireDefault(_show_errors);

var _global_events = __webpack_require__(115);

var _global_events2 = _interopRequireDefault(_global_events);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

$(document).ready(function () {
  var CollectionEditor = Backbone.View.extend({
    whitelist: [
    // Permitted fields provided by ActionKit
    'address1', 'address2', 'city', 'country', 'email', 'first_name', 'last_name', 'middle_name', 'mobile_phone', 'name', 'phone', 'plus4', 'postal', 'prefix', 'region', 'state', 'suffix', 'zip',

    // Common custom fields used by campaigners
    'customer', 'employee', 'shareholder', 'investor'],

    events: {
      'ajax:success #new_collection_element': 'newElementAdded',
      'ajax:success #change-form-template': 'templateChanged',
      'ajax:error a[data-method=delete]': 'deleteFailed',
      'sortupdate .list-group': 'updateSort'
    },

    globalEvents: {
      'survey:form_added': 'autoComplete'
    },

    initialize: function initialize() {
      this.makeSortable();
      this.autoComplete();
      this.$el.on('ajax:success', 'a[data-method=delete]', function () {
        $(this).parents('.list-group-item').fadeOut();
      });
      _global_events2.default.bindEvents(this);
    },

    deleteFailed: function deleteFailed(e, xhr) {
      var message = this.deleteErrorMessage(xhr);
      alert(message);
    },

    deleteErrorMessage: function deleteErrorMessage(xhr) {
      var errors = xhr && xhr.responseJSON && xhr.responseJSON.errors;
      if (!errors || Object.keys(errors).length < 1) return 'That element could not be deleted';
      var firstKey = Object.keys(errors)[0];
      return 'That element ' + errors[firstKey];
    },

    substringMatcher: function substringMatcher(strs) {
      return function findMatches(q, cb) {
        var matches = [];
        var substrRegex = new RegExp(q, 'i');

        // Iterate through the pool of strings and for any string that
        // contains the substring `q`, add it to the `matches` array
        $.each(strs, function (i, str) {
          if (substrRegex.test(str)) {
            matches.push(str);
          }
        });
        cb(matches);
      };
    },

    autoComplete: function autoComplete() {
      var $fields = this.$('.typeahead.typeahead--uninitialized');
      $fields.removeClass('typeahead--uninitialized');
      $fields.typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      }, {
        name: 'fields',
        source: this.substringMatcher(this.whitelist)
      });
    },

    makeSortable: function makeSortable() {
      this.$('.list-group.sortable').sortable();
    },

    updateSort: function updateSort(event, ui, a, b) {
      var ids = ui.item.parent().children().map(function (i, el) {
        return $(el).data('id');
      }).get().join();
      var $form = ui.item.parent().parent().find('form#sort-collection-elements');
      $form.find('#form_element_ids').val(ids);
      $form.submit();
    },

    newElementAdded: function newElementAdded(e, resp, c) {
      var $listGroup = this.$(e.target).parents('.form-customization').find('.list-group');
      $listGroup = $listGroup.length ? $listGroup : this.$('.list-group');
      $listGroup.append(resp);
      this.$('#form_element_label, #form_element_name').val('');
      _show_errors2.default.clearErrors(this.$('form#new_collection_element'));
      Backbone.trigger('collection:element_added');
      this.makeSortable();
    },

    templateChanged: function templateChanged(e, resp) {
      this.$('.forms-edit').html(resp.html);
      this.makeSortable();

      // Updates the inline form's action URL with the new form ID.
      this.$('#sort-collection-elements, #new_collection_element').each(function (i, el) {
        var action = $(el).attr('action').replace(/\d+/, resp.form_id);
        $(el).attr('action', action);
      });
    }
  });

  $.subscribe('collection:edit:loaded', function () {
    (0, _setup_once2.default)('.collection-editor', CollectionEditor);
  });
}); // This file handles the behaviour for managing form building.
//
// Dependencies:
//
//   jQuery.ui.sortable: https://jqueryui.com/sortable/
//   - Allows form fields to be dragged and re-oredered
//
//   Twitter's typeahead: http://twitter.github.io/typeahead.js/
//   - Use for autocompleting for setting the field's name value

/***/ }),

/***/ 442:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


$(function () {
  TALL_EDITORS = ['page_body'];

  function configureWysiwyg(e, id) {
    var $editor = $('#' + id);
    if ($editor.length === 0) {
      return false;
    }

    $editor.summernote({
      toolbar: [['style', ['bold', 'italic', 'underline', 'clear']], ['font', ['fontname', 'fontsize']], ['para', ['ul', 'ol', 'paragraph']], ['color', ['color']], ['insert', ['link', 'picture', 'video']], ['view', ['fullscreen', 'codeview', 'help']]],
      height: TALL_EDITORS.indexOf(id) > -1 ? 280 : 120,
      fontSizes: ['8', '10', '11', '12', '14', '16', '20', '24', '36', '72'],
      codemirror: {
        theme: 'default',
        mode: 'text/html',
        lineNumbers: true,
        tabMode: 'indent',
        lineWrapping: true
      }
    });
    var $contentField = $('#' + id + '_content');

    $editor.summernote('fontSize', '16'); // default
    $editor.summernote('code', $contentField.val());

    // In order to make an iframe size down with the containing column
    // or to fit on screen on mobile, you have to apply style to the iframe
    // and to the containing element. This adds a class to the containing element
    // that our CSS is looking for.
    var encapsulateIframes = function encapsulateIframes(html) {
      if (html.indexOf('iframe') === -1) {
        return html; // don't do anything if there's no iframe
      }
      var $html = $(html);
      // addClass is idempotent so we just call it every time we save
      $html.find('iframe').parent().addClass('iframe-responsive-container');
      // this little goof is just cause jquery doesn't have $el.outerHtml();
      return $('<div></div>').append($html).html();
    };

    var updateContentBeforeSave = function updateContentBeforeSave() {
      var content = encapsulateIframes($editor.summernote('code'));
      $contentField.val(content);
    };

    $.subscribe('wysiwyg:submit', updateContentBeforeSave);
  }

  $.subscribe('wysiwyg:setup', configureWysiwyg);
});

/***/ }),

/***/ 443:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


$(function () {
  var configureDropZone = function configureDropZone() {
    Dropzone.options.dropzone = {
      maxFilesize: 2,
      paramName: 'image[content]',
      addRemoveLinks: false,
      previewsContainer: null,
      createImageThumbnails: true,
      previewTemplate: document.querySelector('#dropzone-preview-template').innerHTML,

      init: function init() {
        this.on('success', function (resp, html) {
          $('.campaign-images .notice').hide();
          $('.dz-success').replaceWith(html);
          var id = $(html).data('image-id');
          $.publish('image:success', [resp, id, html]);
        });

        this.on('addedfiled', function (file) {
          this.removeFile(file);
        });
      }
    };
  };

  var bindHandlers = function bindHandlers() {
    $('.campaign-images').on('ajax:success', 'a[data-method=delete]', function () {
      $(this).parents('.dz-preview').fadeOut();
      var imageId = $(this).parents('[data-image-id]').data('image-id');
      $.publish('image:destroyed', imageId);
    });
  };

  var initialize = function initialize() {
    configureDropZone();
    bindHandlers();
  };

  var addImageOption = function addImageOption(e, file, id, html) {
    var newOption = "<option value='" + id + "'>" + file.name + '</option>';
    $('#page_primary_image_id').append(newOption);
  };

  var removeImageOption = function removeImageOption(e, id) {
    $('#page_primary_image_id').find('option[value="' + id + '"]').remove();
  };

  $.subscribe('dropzone:setup', initialize);
  $.subscribe('image:success', addImageOption);
  $.subscribe('image:destroyed', removeImageOption);
});

/***/ }),

/***/ 444:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _global_events = __webpack_require__(115);

var _global_events2 = _interopRequireDefault(_global_events);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

var FormElementCreator = Backbone.View.extend({
  GENERIC_NAME: 'instruction', // since instruction fields are the only type with no need for a name
  GENERIC_LABEL: 'hidden', // since hidden fields are the only type with no need for a label

  roles: ['defaultValue', 'defaultRevealer', 'choices', 'label', 'name', 'manyChoices'],
  modes: {
    default: ['defaultRevealer', 'label', 'name', 'requirable'],
    hidden: ['defaultValue', 'name'],
    instruction: ['label'],
    choice: ['choices', 'label', 'name', 'requirable'],
    dropdown: ['manyChoices', 'label', 'name', 'requirable', 'defaultRevealer']
  },

  events: {
    'change #form_element_data_type': 'changeFormMode',
    'click .form-element__remove-choice': 'removeChoice',
    'click .form-element__add-choice': 'addChoice'
  },

  globalEvents: {
    'collection:element_added': 'resetAfterSubmission'
  },

  initialize: function initialize() {
    this.changeFormMode({ target: this.$('#form_element_data_type') });
    _global_events2.default.bindEvents(this);
  },
  changeFormMode: function changeFormMode(e) {
    var mode = this.$(e.target).val();
    if (!this.modes.hasOwnProperty(mode)) {
      mode = 'default';
    }
    this.mode = mode;
    this.setModeVisuals(mode);
    this.setModeValues(mode);
  },
  resetAfterSubmission: function resetAfterSubmission() {
    this.setModeVisuals(this.mode);
    this.setModeValues(this.mode);
  },
  setModeVisuals: function setModeVisuals(mode) {
    var _iteratorNormalCompletion = true;
    var _didIteratorError = false;
    var _iteratorError = undefined;

    try {
      for (var _iterator = this.roles[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
        var role = _step.value;

        var $el = this.$('[data-editor-role=' + role + ']');
        $el.toggleClass('hidden-closed', !this.hasField(role, mode));
      }
    } catch (err) {
      _didIteratorError = true;
      _iteratorError = err;
    } finally {
      try {
        if (!_iteratorNormalCompletion && _iterator.return) {
          _iterator.return();
        }
      } finally {
        if (_didIteratorError) {
          throw _iteratorError;
        }
      }
    }
  },
  setModeValues: function setModeValues(mode) {
    if (!this.hasField('choices', mode)) {
      this.resetChoices();
    }
    if (!this.hasField('defaultValue', mode)) {
      this.resetDefaultValue();
    }
    if (!this.hasField('requirable', mode)) {
      this.resetRequired();
    }
    if (this.hasField('name', mode)) {
      this.setNameAwayFromGeneric();
    } else {
      this.setNameToGeneric();
    }
    if (this.hasField('label', mode)) {
      this.setLabelAwayFromGeneric();
    } else {
      this.setLabelToGeneric();
    }
  },
  hasField: function hasField(role, mode) {
    return this.modes[mode].indexOf(role) > -1;
  },
  setNameToGeneric: function setNameToGeneric() {
    this.$('input#form_element_name').val(this.GENERIC_NAME);
  },
  setNameAwayFromGeneric: function setNameAwayFromGeneric() {
    var $nameField = this.$('input#form_element_name');
    if ($nameField.val() === this.GENERIC_NAME) {
      $nameField.val('');
    }
  },
  setLabelToGeneric: function setLabelToGeneric() {
    this.$('input#form_element_label').val(this.GENERIC_LABEL);
  },
  setLabelAwayFromGeneric: function setLabelAwayFromGeneric() {
    var $nameField = this.$('input#form_element_label');
    if ($nameField.val() === this.GENERIC_LABEL) {
      $nameField.val('');
    }
  },
  resetRequired: function resetRequired() {
    this.$('input#form_element_required').prop('checked', false);
  },
  resetDefaultValue: function resetDefaultValue() {
    this.$('input#form_element_default_value').val('');
  },
  resetChoices: function resetChoices() {
    this.ensureCopyableChoiceField();
    this.$('.form-element__choice-fields').html('');
    this.$('.form-element__many-choices-field textarea').val('');
    this.$('.form-element__choice-fields').append(this.$copyableChoiceField.clone());
  },
  ensureCopyableChoiceField: function ensureCopyableChoiceField() {
    if (this.$copyableChoiceField === undefined) {
      this.$copyableChoiceField = this.$('.form-element__choice-field').first().clone();
      this.$copyableChoiceField.find('input').val('');
    }
  },
  addChoice: function addChoice() {
    this.ensureCopyableChoiceField();
    this.$('.form-element__choice-fields').append(this.$copyableChoiceField.clone());
  },
  removeChoice: function removeChoice(e) {
    var $choiceField = this.$(e.target).parents('.form-element__choice-field');
    if (this.$('.form-element__choice-fields').children().length > 1) {
      $choiceField.remove();
    } else {
      $choiceField.find('input').val('');
    }
  }
});

exports.default = FormElementCreator;

/***/ }),

/***/ 445:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


$(function () {
  var fixPreviewElement = function fixPreviewElement() {
    /*
     *
     * NOTE
     * This function is currently not invoked.
     * The plan is to have the preview div fix itself to view
     * so it remains visible as the user scrolls down the page.
     *
     */

    var $preview = $('.plugin-form-preview');

    var originalPosition = $preview.offset(),
        originalTop = originalPosition.top;

    var handleSroll = function handleSroll() {
      var css = { position: 'fixed', top: '0px' };
      if ($(window).scrollTop() >= originalTop) {
        $preview.css(css);
      } else {
        $preview.css({ position: 'static' });
      }
    };

    $(window).scroll(handleSroll);
  };

  var updatePreview = function updatePreview() {
    var updater = function updater(plugin_type) {
      return function (ii, el) {
        var $el = $(el);
        plugin_id = $el.data('plugin-id'), url = ['/plugins/forms/', plugin_type, '/', plugin_id].join('');

        $.get(url, function (resp) {
          $el.find('.plugin-form-preview .content').html(resp);
        });
      };
    };
    $('.plugin.petition').each(updater('petition'));
    $('.plugin.fundraiser').each(updater('fundraiser'));
    $('.plugin.survey').each(updater('survey'));
  };

  if ($('.plugin-form-preview .content').length > 0) {
    $.subscribe('plugin:form:preview:update', updatePreview);
    $.subscribe('page:saved', updatePreview);
  }

  $('.plugin.petition, .plugin.fundraiser, .plugin.survey').on('ajax:success', function () {
    $.publish('plugin:form:preview:update');
  });

  $('.plugin.petition, .plugin.fundraiser, .plugin.survey').on('ajax:error', function (e, xhr, resp) {
    //for debugging
    console.log(xhr, resp);
  });
});

$(function () {
  var bindCaretToggle = function bindCaretToggle() {
    $('[data-toggle="collapse"]').on('click', function (e) {
      $(this).toggleClass('open');
    });
  };

  $.subscribe('plugin:form:loaded', bindCaretToggle);
});

/***/ }),

/***/ 446:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _setup_once = __webpack_require__(276);

var _setup_once2 = _interopRequireDefault(_setup_once);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

$(function () {
  var LayoutPicker = Backbone.View.extend({
    events: {
      'click .radio-group__option': 'updateSelected',
      'change .layout-type-checkbox': 'showRelevantLayouts'
    },

    updateSelected: function updateSelected(e) {
      var $target = $(e.target);
      if (!$target.hasClass('radio-group__option')) {
        // for bubbling
        $target = $target.parents('.radio-group__option');
      }
      var name = $target.find('.layout-settings__title').text();
      $target.parents('.layout-settings').find('.layout-settings__current').text(name);
      $target.parents('.layout-settings').find('.radio-group__option').removeClass('active');
      $target.addClass('active');
      this.updatePlan($target);
    },
    updatePlan: function updatePlan($target) {
      var $input = $target.find('#' + $target.attr('for'));
      if ($input.attr('name') === 'page[follow_up_liquid_layout_id]') {
        this.$('#page_follow_up_plan_with_liquid').prop('checked', true);
      }
    },
    showRelevantLayouts: function showRelevantLayouts(e) {
      var $target = $(e.target);
      var $allRows = $target.closest('.form-group').find('.radio-group__option');
      if ($target.is(':checked')) {
        $allRows.removeClass('hidden');
      } else {
        var layoutClass = this.getLayoutClass($target.attr('id'));
        $allRows.not(layoutClass).addClass('hidden');
      }
    },
    getLayoutClass: function getLayoutClass(layout_select_id) {
      if (layout_select_id === 'primary') {
        return '.primary-layout';
      } else if (layout_select_id === 'follow-up') {
        return '.post-action-layout';
      }
    }
  });

  $.subscribe('layout:edit pages:new', function () {
    (0, _setup_once2.default)('.layout-settings', LayoutPicker);
  });
});

/***/ }),

/***/ 447:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


$(function () {
  var slugChecker = Backbone.Model.extend({
    url: '/action_kit/check_slug',

    defaults: {
      valid: null,
      slug: ''
    }
  });

  var slugView = Backbone.View.extend({
    el: '#new_page',

    events: {
      'keyup #page_title': 'generateSlug',
      'change #page_title': 'generateSlug',
      'keyup #page_slug': 'resetFeedback',
      'click #check_slug_available': 'checkSlugAvailable',
      submit: 'submit'
    },

    initialize: function initialize() {
      this.slugChecker = new slugChecker();
      this.slugChecker.on('change:valid', _.bind(this.updateViewWithValid, this));
      this.cacheDomElements();
      this.checking = false;
    },
    cacheDomElements: function cacheDomElements() {
      this.$title = this.$('#page_title');
      this.$slug = this.$('#page_slug');
      this.$feedback = this.$('.form-group.slug');
      this.$checkButton = this.$('#check_slug_available');
      this.$submit = this.$('.submit-new-page');
    },
    updateViewWithValid: function updateViewWithValid() {
      var valid = this.slugChecker.get('valid');

      this.$submit.removeClass('disabled');

      this.$('.loading').hide();

      this.$('.form-group.slug').removeClass('has-error has-success has-feedback');

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
    generateSlug: function generateSlug() {
      var slug = getSlug(this.$title.val());
      this.resetFeedback();
      this.$slug.val(slug);
    },
    checkSlugAvailable: function checkSlugAvailable(e, cb) {
      var _this = this;

      var slug;

      e.preventDefault();
      this.updateSlug();
      slug = this.$slug.val();

      this.checking = true;

      this.$submit.addClass('disabled');

      this.$('.loading').show();

      this.slugChecker.set('slug', slug);

      this.slugChecker.save().done(function () {
        _this.checking = false;
        _this.$checkButton.text('Check if name is available').removeClass('disabled');

        if (cb) {
          cb.call(_this);
        }
      });
    },
    updateSlug: function updateSlug() {
      var slug = getSlug(this.$slug.val());
      this.resetFeedback();
      this.$slug.val(slug);
    },
    resetFeedback: function resetFeedback() {
      this.$feedback.removeClass('has-error has-success has-feedback');
    },
    submit: function submit(e) {
      var _this2 = this;

      e.preventDefault();

      this.$checkButton.text('Checking...').addClass('disabled');

      if (!this.slugChecker.get('valid')) {
        this.checkSlugAvailable(e, function () {
          if (_this2.slugChecker.get('valid')) {
            _this2.$el.unbind();
            _this2.$el.submit();
          }
        });
      } else {
        this.$el.unbind();
        this.$el.submit();
      }
    }
  });

  var initialize = function initialize() {
    new slugView();
  };

  $.subscribe('pages:new', initialize);
});

/***/ }),

/***/ 448:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _show_errors = __webpack_require__(113);

var _show_errors2 = _interopRequireDefault(_show_errors);

var _lodash = __webpack_require__(22);

var _lodash2 = _interopRequireDefault(_lodash);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

var PageModel = Backbone.Model.extend({
  urlRoot: "/api/pages",

  initialize: function initialize() {
    this.lastSaved = null;
  },

  // override save to only actually save if it's new data
  save: function save(data, callbacks) {
    if (_lodash2.default.isEqual(data, this.lastSaved)) {
      if (typeof callbacks.unchanged === "function") {
        callbacks.unchanged();
      }
    } else {
      this.lastSaved = data;
      Backbone.Model.prototype.save.call(this, data, _lodash2.default.extend({ patch: true }, callbacks));
    }
  },

  setLastSaved: function setLastSaved(data) {
    this.lastSaved = data;
  }
});

var PageEditBar = Backbone.View.extend({
  el: ".page-edit-bar",

  events: {
    "click .page-edit-bar__save-button": "save",
    "click .page-edit-bar__error-message": "findError",
    "change .page-edit-bar__toggle-autosave .onoffswitch__checkbox": "toggleAutosave"
  },

  initialize: function initialize() {
    this.outstandingSaveRequest = false;
    this.addStepsToSidebar();
    this.model = new PageModel();
    this.setupAutosave();
    this.$saveBtn = this.$(".page-edit-bar__save-button");
    $("body").scrollspy({ target: ".scrollspy", offset: 150 });
    this.policeHeights();
  },

  addStepsToSidebar: function addStepsToSidebar() {
    var _this = this;

    var $existing = $("ul.page-edit-bar__step-list li");
    $(".page-edit-step").each(function (ii, step) {
      _this.addStepToSidebar($(step));
    });
    $existing.remove();
    this.$("ul.page-edit-bar__step-list").append($existing);
  },

  addStepToSidebar: function addStepToSidebar($step) {
    var $ul = this.$("ul.page-edit-bar__step-list");
    var title = $step.find(".page-edit-step__title")[0].childNodes[0].nodeValue.trim();
    var id = $step.attr("id");
    var icon = $step.data("icon") || "cubes";
    var link_href = $step.data("link-to") ? $step.data("link-to") : "#" + id;
    var link_target = $step.data("link-to") ? "_blank" : "_self";
    var li = "<li><a href=\"" + link_href + "\" target=\"" + link_target + "\"><i class=\"fa fa-" + icon + "\"></i>" + title + "</a></li>";
    $ul.append(li);
  },

  readData: function readData() {
    var _this2 = this;

    var data = {};
    $("form.one-form").each(function (ii, form) {
      var $form = $(form);
      var type = $form.data("type") || "base";
      if (!data.hasOwnProperty(type)) {
        data[type] = {};
      }
      $.extend(data[type], _this2.serializeForm($form));
    });
    data.id = data.page["page[id]"];
    return data;
  },

  serializeForm: function serializeForm($form) {
    var data = {};
    _lodash2.default.each($form.serializeArray(), function (pair) {
      // this is to handle form arrays cause their name ends in []
      if (pair.name.endsWith("[]")) {
        var name = pair.name.slice(0, -2);
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

  save: function save() {
    $.publish("wysiwyg:submit"); // for summernote + codemirror to update content
    if (!this.outstandingSaveRequest) {
      this.disableSubmit();
      this.model.save(this.readData(), {
        success: this.saved.bind(this),
        error: this.saveFailed.bind(this),
        unchanged: this.enableSubmit.bind(this)
      });
    }
  },

  saved: function saved(e, data) {
    if (data.refresh) {
      location.reload();
    }
    this.enableSubmit();
    $.publish("page:saved", data);
    $(".page-edit-bar__save-box").removeClass("page-edit-bar__save-box--has-error");
    $(".page-edit-bar__error-message").text("");
    $(".page-edit-bar__last-saved").text(I18n.t("pages.edit.last_saved_at", { time: this.currentTime() }));
    this.policeHeights();
  },

  currentTime: function currentTime() {
    var now = new Date();
    var minutes = ("0" + now.getMinutes()).slice(-2); // for leading zero
    var seconds = ("0" + now.getSeconds()).slice(-2); // for leading zero
    return now.getHours() + ":" + minutes + ":" + seconds;
  },

  saveFailed: function saveFailed(e, data) {
    console.error("Save failed with", e, data);
    this.enableSubmit();
    $(".page-edit-bar__save-box").addClass("page-edit-bar__save-box--has-error");
    if (data.status == 422) {
      _show_errors2.default.show(e, data);
      $(".page-edit-bar__error-message").text(I18n.t("pages.edit.user_error"));
      $.publish("page:errors");
    } else {
      $(".page-edit-bar__error-message").text(I18n.t("pages.edit.unknown_error"));
    }
    this.policeHeights();
  },

  findError: function findError() {
    if (this.$(".page-edit-bar__save-box").hasClass("page-edit-bar__save-box--has-error")) {
      if ($(".has-error").length > 0) {
        $("html, body").animate({
          scrollTop: $(".has-error").first().offset().top
        }, 500);
      }
    }
  },

  toggleAutosave: function toggleAutosave(e) {
    var _this3 = this;

    this.autosave = !this.autosave;
    this.$(".page-edit-bar__toggle-autosave").find(".toggle-button").toggleClass("btn-primary");
    if (this.autosave) {
      this.$(".page-edit-bar__btn-holder").addClass("page-edit-bar__btn-holder--hidden");
    } else {
      this.$(".page-edit-bar__btn-holder").removeClass("page-edit-bar__btn-holder--hidden");
    }
    window.setTimeout(function () {
      _this3.policeHeights();
    }, 200);
  },

  disableSubmit: function disableSubmit() {
    this.outstandingSaveRequest = true;
    this.$saveBtn.text(I18n.t("pages.edit.saving"));
    this.$saveBtn.addClass("disabled");
  },

  enableSubmit: function enableSubmit() {
    this.outstandingSaveRequest = false;
    this.$saveBtn.text(I18n.t("pages.edit.save_work"));
    this.$saveBtn.removeClass("disabled");
  },

  setupAutosave: function setupAutosave() {
    var _this4 = this;

    var SAVE_PERIOD = 5000; // milliseconds
    var shouldAutosave = this.$(".page-edit-bar__toggle-autosave").data("autosave") == true;
    this.autosave = true;
    this.model.setLastSaved(this.readData());
    if (shouldAutosave != this.autosave) {
      this.toggleAutosave();
    }
    window.setInterval(function () {
      if (_this4.autosave) {
        _this4.save();
      } else {
        _this4.showUnsavedAlert();
      }
    }, SAVE_PERIOD);
  },

  showUnsavedAlert: function showUnsavedAlert() {
    $.publish("wysiwyg:submit"); // update wysiwyg
    var $lastSaved = $(".page-edit-bar__last-saved");
    var noNotice = $lastSaved.find(".page-edit-bar__unsaved-notice").length < 1;
    var unsavedDataExists = !_lodash2.default.isEqual(this.model.lastSaved, this.readData());
    if (unsavedDataExists) {
      if (noNotice) {
        $lastSaved.append("<div class=\"page-edit-bar__unsaved-notice\">" + I18n.t("pages.edit.unsaved_changes") + "</div>");
      }
    } else {
      $lastSaved.find(".page-edit-bar__unsaved-notice").remove();
    }
  },

  policeHeights: function policeHeights() {
    if ($(window).width() <= 600) {
      return;
    }
    var height = $(window).height() - this.$(".page-edit-bar__logo").height() - this.$(".page-edit-bar__save-box").height() - this.$(".page-edit-bar__btn-holder").outerHeight();
    this.$(".page-edit-bar__step-list").css("height", height + "px");
  }
});

exports.default = PageEditBar;

/***/ }),

/***/ 449:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _setup_once = __webpack_require__(276);

var _setup_once2 = _interopRequireDefault(_setup_once);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

$(function () {
  var ActivationToggle = Backbone.View.extend({
    events: {
      'ajax:before': 'toggleState',
      'ajax:success': 'handleSuccess',
      'ajax:error': 'handleError',
      'change .onoffswitch__checkbox': 'handleClick'
    },

    initialize: function initialize() {
      this.$stateInput = this.$('.activation-toggle-field');
      this.$checkbox = this.$('.onoffswitch__checkbox');
      this.state = this.$stateInput.val();
    },

    handleClick: function handleClick(e) {
      if (this.state == 'published' && this.$stateInput.data('confirm-turning-off')) {
        if (!window.confirm(this.$stateInput.data('confirm-turning-off'))) {
          this.toggleButton();
          return false;
        }
      }
      this.$el.submit();
    },

    toggleButton: function toggleButton() {
      this.$checkbox.prop('checked', !this.$checkbox.prop('checked'));
    },

    handleSuccess: function handleSuccess(e, data) {},

    handleError: function handleError(xhr, status, error) {
      console.error('error', status, error);
      this.toggleButton();
      this.toggleState();
    },

    toggleState: function toggleState(e) {
      if ($(e.target).find('input.onoffswitch__checkbox').hasClass('use-publish-states')) {
        this.state = this.state === 'published' ? 'unpublished' : 'published';
      } else {
        this.state = this.state === 'true' ? 'false' : 'true';
      }
      this.$stateInput.val(this.state);
    }
  });

  $.subscribe('activation:toggle', function () {
    (0, _setup_once2.default)('form.activation-toggle', ActivationToggle);
  });
});

/***/ }),

/***/ 450:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


$(function () {
  var searchConfig = function searchConfig() {
    $('.page-filter__reset').click(function () {
      $('select.selectize-container').map(function (index, item) {
        item.selectize.clear();
      });
      $(this).closest('form').find('.form-control').map(function (index, item) {
        $(item).val('');
      });
    });

    $('#pages-table').DataTable({
      /* Disable initial sort */
      aaSorting: []
    });
  };

  $.subscribe('search:load', searchConfig);
});

/***/ }),

/***/ 451:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


$(function () {
  $('.selectize-container').selectize({
    plugins: ['remove_button'],
    closeAfterSelect: true
  });

  var lastVal;
  $('.selectize-container--clear-on-open').selectize({
    onDropdownOpen: function onDropdownOpen() {
      lastVal = this.getValue();
      this.clear();
    },
    onDropdownClose: function onDropdownClose() {
      if (this.items.length < 1) this.setValue(lastVal);
    },
    closeAfterSelect: true
  });
});

/***/ }),

/***/ 452:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _setup_once = __webpack_require__(276);

var _setup_once2 = _interopRequireDefault(_setup_once);

var _global_events = __webpack_require__(115);

var _global_events2 = _interopRequireDefault(_global_events);

var _clipboard = __webpack_require__(581);

var _clipboard2 = _interopRequireDefault(_clipboard);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

$(function () {
  var SharesEditor = Backbone.View.extend({
    events: {
      'ajax:success form.shares-editor__delete-variant': 'deleteVariant',
      'click .shares-editor__toggle-edit': 'toggleEditor',
      'click .shares-editor__new-type-toggle .btn': 'switchVariantForm',
      'click .shares-editor__view-toggle .btn': 'switchView',
      'ajax:success form.shares-editor__new-form': 'clearFormAndConformView'
    },

    globalEvents: {
      'page:saved': 'updateSummaryRows',
      'page:errors': 'openEditorForErrors',
      'image:success': 'addImageSelectors',
      'image:destroyed': 'pruneImageSelectors'
    },

    initialize: function initialize() {
      this.view = 'summary';
      _global_events2.default.bindEvents(this);
    },

    deleteVariant: function deleteVariant(e) {
      var $target = $(e.target);
      var $summary_row = $target.parents('.shares-editor__summary-row');
      var $stats_row = $summary_row.next('.shares-editor__stats-row');
      var $edit_row = $stats_row.next('.shares-editor__edit-row');
      $summary_row.remove();
      $stats_row.remove();
      $edit_row.remove();
    },

    editRow: function editRow($row) {
      if (!$row.hasClass('shares-editor__stats-row')) {
        $row = $row.next('.shares-editor__stats-row');
      }
      return $row.next('.shares-editor__edit-row');
    },

    toggleEditor: function toggleEditor(e) {
      var $target = this.$(e.target);
      $target = $target.is('tr') ? $target : $target.parents('tr');
      var $btn = $target.find('.shares-editor__toggle-edit');
      this.editRow($target).toggleClass('hidden-closed');
      $btn.text($btn.text() == 'Edit' ? 'Done' : 'Edit');
    },

    openEditor: function openEditor($edit_row) {
      var $prev = $edit_row.prev('.shares-editor__summary-row');
      var $btn = $prev.find('.shares-editor__toggle-edit');
      $btn.text('Done');
      $edit_row.removeClass('hidden-closed');
    },

    switchVariantForm: function switchVariantForm(e) {
      var $target = this.$(e.target);
      var desired = $target.data('state');
      if (desired) {
        this.$('.shares-editor__new-type-toggle .btn').removeClass('btn-primary');
        $target.addClass('btn-primary');
        this.$('.shares-editor__new-form').addClass('hidden-closed');
        this.$('.shares-editor__new-form[data-share="' + desired + '"]').removeClass('hidden-closed');
      }
    },

    switchView: function switchView(e) {
      var $target = this.$(e.target);
      var desired = $target.data('state');
      if (desired) {
        this.setView(desired);
      }
    },

    setView: function setView(desired) {
      this.view = desired;
      this.$('.shares-editor__view-toggle .btn').removeClass('btn-primary');
      this.$('[data-state="' + desired + '"]').addClass('btn-primary');
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

    clearFormAndConformView: function clearFormAndConformView(e) {
      $(e.target).find('input[type="text"], textarea').val('');
      this.setView(this.view); // make new rows conform
    },

    openEditorForErrors: function openEditorForErrors() {
      this.openEditor(this.$('.has-error').parents('.shares-editor__edit-row'));
    },

    updateSummaryRows: function updateSummaryRows(e, data) {
      var _this = this;

      // this only updates existing shares. new ones are appended by
      // code in view/share/shares/create.js.erb, using rails UJS
      $.get('/api/pages/' + data.id + '/share-rows', function (rows) {
        _.each(rows, function (row) {
          var $row = $(row.html);
          var $original = $('#' + $row.prop('id'));
          if ($original.hasClass('hidden-closed')) {
            $row.addClass('hidden-closed');
          }
          $row = $original.replaceWith($row);
          $row = $('#' + $row.prop('id'));
          if (!_this.editRow($row).hasClass('hidden-closed')) {
            $row.find('.shares-editor__toggle-edit').text('Done');
          }
        });
      });
    },

    addImageSelectors: function addImageSelectors(e, file, id, html) {
      var newOption = '<option value=\'' + id + '\'>' + file.name + '</option>';
      this.$('.shares-editor__image-selector').append(newOption);
    },

    pruneImageSelectors: function pruneImageSelectors(e, id) {
      this.$('option[value="' + id + '"]').remove();
    }
  });

  $.subscribe('shares:edit', function () {
    (0, _setup_once2.default)('.shares-editor', SharesEditor);
  });
});

$(function () {
  new _clipboard2.default('.share-copy-url');

  $('.shares-editor__existing').on('click', '.share-copy-url', function (e) {
    e.preventDefault();
  });
});

/***/ }),

/***/ 453:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _setup_once = __webpack_require__(276);

var _setup_once2 = _interopRequireDefault(_setup_once);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

$(function () {
  var Sidebar = Backbone.View.extend({
    events: {
      'click .sidebar__header-link': 'toggleGroup'
    },

    toggleGroup: function toggleGroup(e) {
      var $group = $(e.target).parents('.sidebar__group');
      $group.toggleClass('sidebar__group--closed sidebar__group--open');
    }
  });

  $.subscribe('sidebar:nesting', function () {
    (0, _setup_once2.default)('.sidebar', Sidebar);
  });
});

/***/ }),

/***/ 454:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _global_events = __webpack_require__(115);

var _global_events2 = _interopRequireDefault(_global_events);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

var SurveyEditor = Backbone.View.extend({
  el: '.survey',

  events: {
    'sortupdate .survey__forms': 'handleSort'
  },

  globalEvents: {
    'survey:form_added': 'makeSortable'
  },

  initialize: function initialize() {
    var options = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

    this.makeSortable();
    this.id = this.$el.data('plugin-id');
    _global_events2.default.bindEvents(this);
  },
  makeSortable: function makeSortable() {
    this.$('.survey__forms').sortable();
  },
  handleSort: function handleSort(e, ui) {
    var _this = this;

    if (!$(e.target).hasClass('survey__forms')) return;
    var ids = ui.item.parent().children().map(function (i, el) {
      return _this.$(el).data('id');
    }).get();
    this.saveFormOrder(ids);
  },
  saveFormOrder: function saveFormOrder(ids) {
    $.ajax('/plugins/surveys/' + this.id + '/sort', {
      method: 'PUT',
      data: { form_ids: ids.join(',') }
    }).done(function () {
      $.publish('plugin:form:preview:update');
    });
  }
});

exports.default = SurveyEditor;

/***/ }),

/***/ 455:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


// This depends on codemirror and its modes being required in
// `app/assets/javascripts/application.js`

$(function () {
  $('.syntax-highlighting').each(function (idx, el) {
    var mode = $(el).data('highlight-mode') || 'htmlmixed';
    var cm = CodeMirror.fromTextArea(el, {
      mode: mode,
      theme: '3024-night'
    });
    $.subscribe('wysiwyg:submit', cm.save);
  });
});

/***/ }),

/***/ 456:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


$(function () {
  $.subscribe('pages:new pages:edit form:edit pages:analytics', function () {
    $('[data-toggle="tooltip"]').tooltip();
  });
});

/***/ }),

/***/ 524:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


__webpack_require__(315);

__webpack_require__(113);

__webpack_require__(455);

__webpack_require__(443);

__webpack_require__(451);

__webpack_require__(450);

__webpack_require__(442);

__webpack_require__(445);

__webpack_require__(439);

__webpack_require__(447);

__webpack_require__(449);

__webpack_require__(453);

__webpack_require__(456);

__webpack_require__(441);

__webpack_require__(452);

__webpack_require__(438);

__webpack_require__(446);

var _page_edit_bar = __webpack_require__(448);

var _page_edit_bar2 = _interopRequireDefault(_page_edit_bar);

var _analytics = __webpack_require__(440);

var _analytics2 = _interopRequireDefault(_analytics);

var _survey_editor = __webpack_require__(454);

var _survey_editor2 = _interopRequireDefault(_survey_editor);

var _form_element_creator = __webpack_require__(444);

var _form_element_creator2 = _interopRequireDefault(_form_element_creator);

function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}

Object.assign(window, {
  PageEditBar: _page_edit_bar2.default,
  Analytics: _analytics2.default,
  SurveyEditor: _survey_editor2.default,
  FormElementCreator: _form_element_creator2.default
}); // Copied over from previous file in
// assets/javascripts/application.js manifest
// A lot of this might be unnecessary (and it will do well
// to reduce bundle size)

// TODO: Refactor this to *not* get imported into the global scope

/***/ }),

/***/ 580:
/***/ (function(module, exports, __webpack_require__) {

var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;(function (global, factory) {
    if (true) {
        !(__WEBPACK_AMD_DEFINE_ARRAY__ = [module, __webpack_require__(656)], __WEBPACK_AMD_DEFINE_FACTORY__ = (factory),
				__WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ?
				(__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
    } else if (typeof exports !== "undefined") {
        factory(module, require('select'));
    } else {
        var mod = {
            exports: {}
        };
        factory(mod, global.select);
        global.clipboardAction = mod.exports;
    }
})(this, function (module, _select) {
    'use strict';

    var _select2 = _interopRequireDefault(_select);

    function _interopRequireDefault(obj) {
        return obj && obj.__esModule ? obj : {
            default: obj
        };
    }

    var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) {
        return typeof obj;
    } : function (obj) {
        return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj;
    };

    function _classCallCheck(instance, Constructor) {
        if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
        }
    }

    var _createClass = function () {
        function defineProperties(target, props) {
            for (var i = 0; i < props.length; i++) {
                var descriptor = props[i];
                descriptor.enumerable = descriptor.enumerable || false;
                descriptor.configurable = true;
                if ("value" in descriptor) descriptor.writable = true;
                Object.defineProperty(target, descriptor.key, descriptor);
            }
        }

        return function (Constructor, protoProps, staticProps) {
            if (protoProps) defineProperties(Constructor.prototype, protoProps);
            if (staticProps) defineProperties(Constructor, staticProps);
            return Constructor;
        };
    }();

    var ClipboardAction = function () {
        /**
         * @param {Object} options
         */
        function ClipboardAction(options) {
            _classCallCheck(this, ClipboardAction);

            this.resolveOptions(options);
            this.initSelection();
        }

        /**
         * Defines base properties passed from constructor.
         * @param {Object} options
         */


        _createClass(ClipboardAction, [{
            key: 'resolveOptions',
            value: function resolveOptions() {
                var options = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

                this.action = options.action;
                this.container = options.container;
                this.emitter = options.emitter;
                this.target = options.target;
                this.text = options.text;
                this.trigger = options.trigger;

                this.selectedText = '';
            }
        }, {
            key: 'initSelection',
            value: function initSelection() {
                if (this.text) {
                    this.selectFake();
                } else if (this.target) {
                    this.selectTarget();
                }
            }
        }, {
            key: 'selectFake',
            value: function selectFake() {
                var _this = this;

                var isRTL = document.documentElement.getAttribute('dir') == 'rtl';

                this.removeFake();

                this.fakeHandlerCallback = function () {
                    return _this.removeFake();
                };
                this.fakeHandler = this.container.addEventListener('click', this.fakeHandlerCallback) || true;

                this.fakeElem = document.createElement('textarea');
                // Prevent zooming on iOS
                this.fakeElem.style.fontSize = '12pt';
                // Reset box model
                this.fakeElem.style.border = '0';
                this.fakeElem.style.padding = '0';
                this.fakeElem.style.margin = '0';
                // Move element out of screen horizontally
                this.fakeElem.style.position = 'absolute';
                this.fakeElem.style[isRTL ? 'right' : 'left'] = '-9999px';
                // Move element to the same position vertically
                var yPosition = window.pageYOffset || document.documentElement.scrollTop;
                this.fakeElem.style.top = yPosition + 'px';

                this.fakeElem.setAttribute('readonly', '');
                this.fakeElem.value = this.text;

                this.container.appendChild(this.fakeElem);

                this.selectedText = (0, _select2.default)(this.fakeElem);
                this.copyText();
            }
        }, {
            key: 'removeFake',
            value: function removeFake() {
                if (this.fakeHandler) {
                    this.container.removeEventListener('click', this.fakeHandlerCallback);
                    this.fakeHandler = null;
                    this.fakeHandlerCallback = null;
                }

                if (this.fakeElem) {
                    this.container.removeChild(this.fakeElem);
                    this.fakeElem = null;
                }
            }
        }, {
            key: 'selectTarget',
            value: function selectTarget() {
                this.selectedText = (0, _select2.default)(this.target);
                this.copyText();
            }
        }, {
            key: 'copyText',
            value: function copyText() {
                var succeeded = void 0;

                try {
                    succeeded = document.execCommand(this.action);
                } catch (err) {
                    succeeded = false;
                }

                this.handleResult(succeeded);
            }
        }, {
            key: 'handleResult',
            value: function handleResult(succeeded) {
                this.emitter.emit(succeeded ? 'success' : 'error', {
                    action: this.action,
                    text: this.selectedText,
                    trigger: this.trigger,
                    clearSelection: this.clearSelection.bind(this)
                });
            }
        }, {
            key: 'clearSelection',
            value: function clearSelection() {
                if (this.trigger) {
                    this.trigger.focus();
                }

                window.getSelection().removeAllRanges();
            }
        }, {
            key: 'destroy',
            value: function destroy() {
                this.removeFake();
            }
        }, {
            key: 'action',
            set: function set() {
                var action = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'copy';

                this._action = action;

                if (this._action !== 'copy' && this._action !== 'cut') {
                    throw new Error('Invalid "action" value, use either "copy" or "cut"');
                }
            },
            get: function get() {
                return this._action;
            }
        }, {
            key: 'target',
            set: function set(target) {
                if (target !== undefined) {
                    if (target && (typeof target === 'undefined' ? 'undefined' : _typeof(target)) === 'object' && target.nodeType === 1) {
                        if (this.action === 'copy' && target.hasAttribute('disabled')) {
                            throw new Error('Invalid "target" attribute. Please use "readonly" instead of "disabled" attribute');
                        }

                        if (this.action === 'cut' && (target.hasAttribute('readonly') || target.hasAttribute('disabled'))) {
                            throw new Error('Invalid "target" attribute. You can\'t cut text from elements with "readonly" or "disabled" attributes');
                        }

                        this._target = target;
                    } else {
                        throw new Error('Invalid "target" value, use a valid Element');
                    }
                }
            },
            get: function get() {
                return this._target;
            }
        }]);

        return ClipboardAction;
    }();

    module.exports = ClipboardAction;
});

/***/ }),

/***/ 581:
/***/ (function(module, exports, __webpack_require__) {

var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;(function (global, factory) {
    if (true) {
        !(__WEBPACK_AMD_DEFINE_ARRAY__ = [module, __webpack_require__(580), __webpack_require__(662), __webpack_require__(622)], __WEBPACK_AMD_DEFINE_FACTORY__ = (factory),
				__WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ?
				(__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
    } else if (typeof exports !== "undefined") {
        factory(module, require('./clipboard-action'), require('tiny-emitter'), require('good-listener'));
    } else {
        var mod = {
            exports: {}
        };
        factory(mod, global.clipboardAction, global.tinyEmitter, global.goodListener);
        global.clipboard = mod.exports;
    }
})(this, function (module, _clipboardAction, _tinyEmitter, _goodListener) {
    'use strict';

    var _clipboardAction2 = _interopRequireDefault(_clipboardAction);

    var _tinyEmitter2 = _interopRequireDefault(_tinyEmitter);

    var _goodListener2 = _interopRequireDefault(_goodListener);

    function _interopRequireDefault(obj) {
        return obj && obj.__esModule ? obj : {
            default: obj
        };
    }

    var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) {
        return typeof obj;
    } : function (obj) {
        return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj;
    };

    function _classCallCheck(instance, Constructor) {
        if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
        }
    }

    var _createClass = function () {
        function defineProperties(target, props) {
            for (var i = 0; i < props.length; i++) {
                var descriptor = props[i];
                descriptor.enumerable = descriptor.enumerable || false;
                descriptor.configurable = true;
                if ("value" in descriptor) descriptor.writable = true;
                Object.defineProperty(target, descriptor.key, descriptor);
            }
        }

        return function (Constructor, protoProps, staticProps) {
            if (protoProps) defineProperties(Constructor.prototype, protoProps);
            if (staticProps) defineProperties(Constructor, staticProps);
            return Constructor;
        };
    }();

    function _possibleConstructorReturn(self, call) {
        if (!self) {
            throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
        }

        return call && (typeof call === "object" || typeof call === "function") ? call : self;
    }

    function _inherits(subClass, superClass) {
        if (typeof superClass !== "function" && superClass !== null) {
            throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
        }

        subClass.prototype = Object.create(superClass && superClass.prototype, {
            constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }
        });
        if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
    }

    var Clipboard = function (_Emitter) {
        _inherits(Clipboard, _Emitter);

        /**
         * @param {String|HTMLElement|HTMLCollection|NodeList} trigger
         * @param {Object} options
         */
        function Clipboard(trigger, options) {
            _classCallCheck(this, Clipboard);

            var _this = _possibleConstructorReturn(this, (Clipboard.__proto__ || Object.getPrototypeOf(Clipboard)).call(this));

            _this.resolveOptions(options);
            _this.listenClick(trigger);
            return _this;
        }

        /**
         * Defines if attributes would be resolved using internal setter functions
         * or custom functions that were passed in the constructor.
         * @param {Object} options
         */


        _createClass(Clipboard, [{
            key: 'resolveOptions',
            value: function resolveOptions() {
                var options = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

                this.action = typeof options.action === 'function' ? options.action : this.defaultAction;
                this.target = typeof options.target === 'function' ? options.target : this.defaultTarget;
                this.text = typeof options.text === 'function' ? options.text : this.defaultText;
                this.container = _typeof(options.container) === 'object' ? options.container : document.body;
            }
        }, {
            key: 'listenClick',
            value: function listenClick(trigger) {
                var _this2 = this;

                this.listener = (0, _goodListener2.default)(trigger, 'click', function (e) {
                    return _this2.onClick(e);
                });
            }
        }, {
            key: 'onClick',
            value: function onClick(e) {
                var trigger = e.delegateTarget || e.currentTarget;

                if (this.clipboardAction) {
                    this.clipboardAction = null;
                }

                this.clipboardAction = new _clipboardAction2.default({
                    action: this.action(trigger),
                    target: this.target(trigger),
                    text: this.text(trigger),
                    container: this.container,
                    trigger: trigger,
                    emitter: this
                });
            }
        }, {
            key: 'defaultAction',
            value: function defaultAction(trigger) {
                return getAttributeValue('action', trigger);
            }
        }, {
            key: 'defaultTarget',
            value: function defaultTarget(trigger) {
                var selector = getAttributeValue('target', trigger);

                if (selector) {
                    return document.querySelector(selector);
                }
            }
        }, {
            key: 'defaultText',
            value: function defaultText(trigger) {
                return getAttributeValue('text', trigger);
            }
        }, {
            key: 'destroy',
            value: function destroy() {
                this.listener.destroy();

                if (this.clipboardAction) {
                    this.clipboardAction.destroy();
                    this.clipboardAction = null;
                }
            }
        }], [{
            key: 'isSupported',
            value: function isSupported() {
                var action = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : ['copy', 'cut'];

                var actions = typeof action === 'string' ? [action] : action;
                var support = !!document.queryCommandSupported;

                actions.forEach(function (action) {
                    support = support && !!document.queryCommandSupported(action);
                });

                return support;
            }
        }]);

        return Clipboard;
    }(_tinyEmitter2.default);

    /**
     * Helper function to retrieve attribute value.
     * @param {String} suffix
     * @param {Element} element
     */
    function getAttributeValue(suffix, element) {
        var attribute = 'data-clipboard-' + suffix;

        if (!element.hasAttribute(attribute)) {
            return;
        }

        return element.getAttribute(attribute);
    }

    module.exports = Clipboard;
});

/***/ }),

/***/ 588:
/***/ (function(module, exports) {

var DOCUMENT_NODE_TYPE = 9;

/**
 * A polyfill for Element.matches()
 */
if (typeof Element !== 'undefined' && !Element.prototype.matches) {
    var proto = Element.prototype;

    proto.matches = proto.matchesSelector ||
                    proto.mozMatchesSelector ||
                    proto.msMatchesSelector ||
                    proto.oMatchesSelector ||
                    proto.webkitMatchesSelector;
}

/**
 * Finds the closest parent that matches a selector.
 *
 * @param {Element} element
 * @param {String} selector
 * @return {Function}
 */
function closest (element, selector) {
    while (element && element.nodeType !== DOCUMENT_NODE_TYPE) {
        if (typeof element.matches === 'function' &&
            element.matches(selector)) {
          return element;
        }
        element = element.parentNode;
    }
}

module.exports = closest;


/***/ }),

/***/ 589:
/***/ (function(module, exports, __webpack_require__) {

var closest = __webpack_require__(588);

/**
 * Delegates event to a selector.
 *
 * @param {Element} element
 * @param {String} selector
 * @param {String} type
 * @param {Function} callback
 * @param {Boolean} useCapture
 * @return {Object}
 */
function delegate(element, selector, type, callback, useCapture) {
    var listenerFn = listener.apply(this, arguments);

    element.addEventListener(type, listenerFn, useCapture);

    return {
        destroy: function() {
            element.removeEventListener(type, listenerFn, useCapture);
        }
    }
}

/**
 * Finds closest match and invokes callback.
 *
 * @param {Element} element
 * @param {String} selector
 * @param {String} type
 * @param {Function} callback
 * @return {Function}
 */
function listener(element, selector, type, callback) {
    return function(e) {
        e.delegateTarget = closest(e.target, selector);

        if (e.delegateTarget) {
            callback.call(element, e);
        }
    }
}

module.exports = delegate;


/***/ }),

/***/ 621:
/***/ (function(module, exports) {

/**
 * Check if argument is a HTML element.
 *
 * @param {Object} value
 * @return {Boolean}
 */
exports.node = function(value) {
    return value !== undefined
        && value instanceof HTMLElement
        && value.nodeType === 1;
};

/**
 * Check if argument is a list of HTML elements.
 *
 * @param {Object} value
 * @return {Boolean}
 */
exports.nodeList = function(value) {
    var type = Object.prototype.toString.call(value);

    return value !== undefined
        && (type === '[object NodeList]' || type === '[object HTMLCollection]')
        && ('length' in value)
        && (value.length === 0 || exports.node(value[0]));
};

/**
 * Check if argument is a string.
 *
 * @param {Object} value
 * @return {Boolean}
 */
exports.string = function(value) {
    return typeof value === 'string'
        || value instanceof String;
};

/**
 * Check if argument is a function.
 *
 * @param {Object} value
 * @return {Boolean}
 */
exports.fn = function(value) {
    var type = Object.prototype.toString.call(value);

    return type === '[object Function]';
};


/***/ }),

/***/ 622:
/***/ (function(module, exports, __webpack_require__) {

var is = __webpack_require__(621);
var delegate = __webpack_require__(589);

/**
 * Validates all params and calls the right
 * listener function based on its target type.
 *
 * @param {String|HTMLElement|HTMLCollection|NodeList} target
 * @param {String} type
 * @param {Function} callback
 * @return {Object}
 */
function listen(target, type, callback) {
    if (!target && !type && !callback) {
        throw new Error('Missing required arguments');
    }

    if (!is.string(type)) {
        throw new TypeError('Second argument must be a String');
    }

    if (!is.fn(callback)) {
        throw new TypeError('Third argument must be a Function');
    }

    if (is.node(target)) {
        return listenNode(target, type, callback);
    }
    else if (is.nodeList(target)) {
        return listenNodeList(target, type, callback);
    }
    else if (is.string(target)) {
        return listenSelector(target, type, callback);
    }
    else {
        throw new TypeError('First argument must be a String, HTMLElement, HTMLCollection, or NodeList');
    }
}

/**
 * Adds an event listener to a HTML element
 * and returns a remove listener function.
 *
 * @param {HTMLElement} node
 * @param {String} type
 * @param {Function} callback
 * @return {Object}
 */
function listenNode(node, type, callback) {
    node.addEventListener(type, callback);

    return {
        destroy: function() {
            node.removeEventListener(type, callback);
        }
    }
}

/**
 * Add an event listener to a list of HTML elements
 * and returns a remove listener function.
 *
 * @param {NodeList|HTMLCollection} nodeList
 * @param {String} type
 * @param {Function} callback
 * @return {Object}
 */
function listenNodeList(nodeList, type, callback) {
    Array.prototype.forEach.call(nodeList, function(node) {
        node.addEventListener(type, callback);
    });

    return {
        destroy: function() {
            Array.prototype.forEach.call(nodeList, function(node) {
                node.removeEventListener(type, callback);
            });
        }
    }
}

/**
 * Add an event listener to a selector
 * and returns a remove listener function.
 *
 * @param {String} selector
 * @param {String} type
 * @param {Function} callback
 * @return {Object}
 */
function listenSelector(selector, type, callback) {
    return delegate(document.body, selector, type, callback);
}

module.exports = listen;


/***/ }),

/***/ 656:
/***/ (function(module, exports) {

function select(element) {
    var selectedText;

    if (element.nodeName === 'SELECT') {
        element.focus();

        selectedText = element.value;
    }
    else if (element.nodeName === 'INPUT' || element.nodeName === 'TEXTAREA') {
        var isReadOnly = element.hasAttribute('readonly');

        if (!isReadOnly) {
            element.setAttribute('readonly', '');
        }

        element.select();
        element.setSelectionRange(0, element.value.length);

        if (!isReadOnly) {
            element.removeAttribute('readonly');
        }

        selectedText = element.value;
    }
    else {
        if (element.hasAttribute('contenteditable')) {
            element.focus();
        }

        var selection = window.getSelection();
        var range = document.createRange();

        range.selectNodeContents(element);
        selection.removeAllRanges();
        selection.addRange(range);

        selectedText = selection.toString();
    }

    return selectedText;
}

module.exports = select;


/***/ }),

/***/ 662:
/***/ (function(module, exports) {

function E () {
  // Keep this empty so it's easier to inherit from
  // (via https://github.com/lipsmack from https://github.com/scottcorgan/tiny-emitter/issues/3)
}

E.prototype = {
  on: function (name, callback, ctx) {
    var e = this.e || (this.e = {});

    (e[name] || (e[name] = [])).push({
      fn: callback,
      ctx: ctx
    });

    return this;
  },

  once: function (name, callback, ctx) {
    var self = this;
    function listener () {
      self.off(name, listener);
      callback.apply(ctx, arguments);
    };

    listener._ = callback
    return this.on(name, listener, ctx);
  },

  emit: function (name) {
    var data = [].slice.call(arguments, 1);
    var evtArr = ((this.e || (this.e = {}))[name] || []).slice();
    var i = 0;
    var len = evtArr.length;

    for (i; i < len; i++) {
      evtArr[i].fn.apply(evtArr[i].ctx, data);
    }

    return this;
  },

  off: function (name, callback) {
    var e = this.e || (this.e = {});
    var evts = e[name];
    var liveEvents = [];

    if (evts && callback) {
      for (var i = 0, len = evts.length; i < len; i++) {
        if (evts[i].fn !== callback && evts[i].fn._ !== callback)
          liveEvents.push(evts[i]);
      }
    }

    // Remove event from queue to prevent memory leak
    // Suggested by https://github.com/lazd
    // Ref: https://github.com/scottcorgan/tiny-emitter/commit/c6ebfaa9bc973b33d110a84a307742b7cf94c953#commitcomment-5024910

    (liveEvents.length)
      ? e[name] = liveEvents
      : delete e[name];

    return this;
  }
};

module.exports = E;


/***/ }),

/***/ 78:
/***/ (function(module, exports) {

module.exports = window.Backbone;

/***/ })

/******/ });