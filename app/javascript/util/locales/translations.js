import { sanitizeTranslations } from './helpers';

export default sanitizeTranslations({
  ...require('../../../../config/locales/member_facing.de.yml'),
  ...require('../../../../config/locales/member_facing.en.yml'),
  ...require('../../../../config/locales/member_facing.fr.yml'),
});
