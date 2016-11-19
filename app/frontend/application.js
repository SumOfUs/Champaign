/* @flow */
import React from 'react';
import { render } from 'react-dom';
import { addLocaleData } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import esLocaleData from 'react-intl/locale-data/es';

import configureStore from './state';
import ComponentWrapper from './ComponentWrapper';

import FundraiserView from './containers/FundraiserView/FundraiserView';

import './application.css';

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);

window.initializeStore = configureStore;
window.FundraiserComponent = FundraiserView;

window.mountComponent = (root: string, Component: ReactClass<any>, props: any = {}, initialState?: any = {}) => {
  const store: Store = props.store;
  if (store) {
    store.dispatch({ type: 'parse_champaign_data', payload: window.champaign.personalization });
  }

  render(
    <ComponentWrapper store={props.store}>
      <Component {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );

  /* FIXME: this doesn't work because we're injecting a child into the wrapper
  /*        so we need to create individual outputs / chunks for each Component
  /*        and we're game (hot reloading!) */
  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('./ComponentWrapper', () => {
      const UpdatedComponentWrapper = require('./ComponentWrapper').default;
      render(
        <UpdatedComponentWrapper store={props.store}>
          <Component {...props} />
        </UpdatedComponentWrapper>,
        document.getElementById(root)
      );
    });
  }
};
