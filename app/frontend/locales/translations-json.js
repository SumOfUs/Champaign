// This file is mainly used for JEST, because Jest can't
// load YAML files.
// npm run test runs a task that converts translations to json
// files *before* tests are run, and we mock the translations.js
// file in jest so that it requires this file, which would "just work".

import { sanitizeTranslations } from './helpers';

export default sanitizeTranslations({
  ...require('./member_facing.en'),
  ...require('./member_facing.de'),
  ...require('./member_facing.fr'),
});
