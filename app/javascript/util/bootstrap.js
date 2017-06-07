import 'babel-polyfill';
import { addLocaleData } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import esLocaleData from 'react-intl/locale-data/es';

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);
