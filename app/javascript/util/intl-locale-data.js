// @flow
import { addLocaleData } from 'react-intl';
import enLocaleData from 'intl/locale-data/jsonp/en';
import deLocaleData from 'intl/locale-data/jsonp/de';
import frLocaleData from 'intl/locale-data/jsonp/fr';

addLocaleData([...enLocaleData, ...deLocaleData, ...frLocaleData]);
