#!/usr/bin/env node
const YAML = require('yamljs');
const path = require('path');
const fs = require('fs');

const DEST_PATH = path.resolve('app', 'frontend', 'locales');

try {
  fs.mkdirSync(DEST_PATH);
} catch (e) { /* do nothing, ignore EEXIST */ }

['en', 'de', 'fr'].forEach(convert);

function convert(language) {
  const destFile = path.resolve(DEST_PATH, `member_facing.${language}.json`);
  const text = fs.readFileSync(`./config/locales/member_facing.${language}.yml`, 'utf8');
  const data = YAML.parse(text);
  fs.writeFileSync(destFile, JSON.stringify(data));
}
