/* @flow */
import React from 'react';
import { render } from 'react-dom';
import { addLocaleData } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import esLocaleData from 'react-intl/locale-data/es';

import configureStore from '../../state';
import ComponentWrapper from '../../ComponentWrapper';
import FundraiserView from './FundraiserView';

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);

window.initializeStore = configureStore;

window.mountFundraiser = (root, props: any = {}) => {
  render(
    <ComponentWrapper store={props.store}>
      <FundraiserView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );

  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('./FundraiserView', () => {
      const UpdatedComponentWrapper = require('./FundraiserView').default;
      render(
        <UpdatedComponentWrapper store={props.store}>
          <FundraiserView {...props} />
        </UpdatedComponentWrapper>,
        document.getElementById(root)
      );
    });
  }
};
