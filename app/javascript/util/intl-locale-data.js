// @flow
import { addLocaleData } from 'react-intl';

if (!window.Intl) {
  import('intl').then(() => {
    require('intl/locale-data/jsonp/en');
    require('intl/locale-data/jsonp/de');
    require('intl/locale-data/jsonp/fr');
  });
} else {
  addLocaleData([
    ...require('react-intl/locale-data/en'),
    ...require('react-intl/locale-data/de'),
    ...require('react-intl/locale-data/fr'),
  ]);
}
