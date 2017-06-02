// Copied over from previous file in
// assets/javascripts/application.js manifest
// A lot of this might be unnecessary (and it will do well
// to reduce bundle size)

// NPM modules
import 'jquery';
import 'jquery_ujs';
import 'lodash';
import 'backbone';
import 'jquery-ui/widgets/sortable';
import 'jquery.remotipart';
import 'd3';
import 'odometer';
import 'moment';
import 'bootstrap-sprockets';
import 'selectize';
import 'dropzone';
import 'typeahead.jquery';
import 'speakingurl';
import 'summernote';
import 'datatables';
import 'datatables/dataTables.bootstrap';
import 'i18n';
import 'i18n/translations';

// App code
// TODO: Refactor this to *not* get imported into the global scope
import '../shared/pub_sub';
import '../shared/show_errors';
import '../campaigner_facing/syntax_highlighting';
import '../campaigner_facing/dropzone_image_upload';
import '../campaigner_facing/selectize_config';
import '../campaigner_facing/search';
import '../campaigner_facing/configure_wysiwyg';
import '../campaigner_facing/form_preview';
import '../campaigner-facing/ajax';
import '../campaigner-facing/page';
import '../campaigner-facing/plugins_toggle';
import '../campaigner-facing/sidebar';
import '../campaigner-facing/tooltips';
import '../campaigner-facing/collection_editor';
import '../campaigner-facing/shares_editor';
import '../campaigner-facing/actions_editor';
import '../campaigner-facing/layout_picker';

import PageEditBar from '../campaigner-facing/page_edit_bar';
import Analytics from '../campaigner-facing/analytics';
import SurveyEditor from '../campaigner-facing/survey_editor';
import FormElementCreator from '../campaigner-facing/form_element_creator';

Object.assign(window, {
  PageEditBar,
  Analytics,
  SurveyEditor,
  FormElementCreator,
});
