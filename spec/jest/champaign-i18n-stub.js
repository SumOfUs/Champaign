import YAML from 'yamljs';
import fs from 'fs';

export const translations = {
  ...YAML.parse(
    fs.readFileSync('./config/locales/member_facing.de.yml', 'utf8')
  ),
  ...YAML.parse(
    fs.readFileSync('./config/locales/member_facing.en.yml', 'utf8')
  ),
  ...YAML.parse(
    fs.readFileSync('./config/locales/member_facing.fr.yml', 'utf8')
  ),
  ...YAML.parse(
    fs.readFileSync('./config/locales/member_facing.es.yml', 'utf8')
  ),
};

export default {
  translations,
};
