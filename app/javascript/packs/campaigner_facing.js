// @flow
// Copied over from previous file in
// assets/javascripts/application.js manifest
// A lot of this might be unnecessary (and it will do well
// to reduce bundle size)

// TODO: Refactor this to *not* get imported into the global scope
require('d3');
import '../shared/pub_sub';
import '../shared/show_errors';
import '../legacy/campaigner_facing/syntax_highlighting';
import '../legacy/campaigner_facing/dropzone_image_upload';
import '../legacy/campaigner_facing/selectize_config';
import '../legacy/campaigner_facing/search';
import '../legacy/campaigner_facing/configure_wysiwyg';
import '../legacy/campaigner_facing/form_preview';
import '../legacy/campaigner_facing/ajax';
import '../legacy/campaigner_facing/page';
import '../legacy/campaigner_facing/plugins_toggle';
import '../legacy/campaigner_facing/sidebar';
import '../legacy/campaigner_facing/tooltips';
import '../legacy/campaigner_facing/collection_editor';
import '../legacy/campaigner_facing/shares_editor';
import '../legacy/campaigner_facing/actions_editor';
import '../legacy/campaigner_facing/layout_picker';

import PageEditBar from '../legacy/campaigner_facing/page_edit_bar';
import Analytics from '../legacy/campaigner_facing/analytics';
import SurveyEditor from '../legacy/campaigner_facing/survey_editor';
import FormElementCreator from '../legacy/campaigner_facing/form_element_creator';
import ListEditor from '../legacy/campaigner_facing/list_editor';
import Twitter from 'twitter-text';

// Styles
import 'c3/c3.css';

require('backbone');
require('lodash');
require('jquery-ui/ui/widgets/sortable');
require('jquery-typeahead');

Object.assign(window, {
  PageEditBar,
  Analytics,
  SurveyEditor,
  FormElementCreator,
  ListEditor,
  Twitter,
});
