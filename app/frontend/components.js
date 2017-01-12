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

import './components.css';

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);

window.initializeStore = configureStore;

window.mountFundraiser = (root: string, store?: Store, initialState?: any = {})  => {
  if (store) {
    store.dispatch({ type: 'parse_champaign_data', payload: initialState });
  }

  render(
    <ComponentWrapper store={store} locale={initialState['locale']}>
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById(root)
  );

  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('./containers/FundraiserView/FundraiserView', () => {
      const UpdatedFundraiserView = require('./containers/FundraiserView/FundraiserView').default;
      render(
        <ComponentWrapper store={store} locale={initialState['locale']}>
          <UpdatedFundraiserView />
        </ComponentWrapper>,
        document.getElementById(root)
      );
    });
  }
};

// Call Tool -----------------

import CallToolView   from './containers/CallToolView/CallToolView';
import callToolReducer from './state/callTool/reducer';
import { createStore } from 'redux';
import { camelizeKeys } from './util/util';

window.mountCallTool = (root, props) => {
  // Store not being used yet. And if we use it, should we use
  // the same store as the fundraiser component?
  const store = createStore(callToolReducer);
  props = camelizeKeys(props);

  render(
    <ComponentWrapper store={store} locale={props.locale}>
      <CallToolView
        title={props.title}
        targets={props.targets}
        targetCountries={props.targetCountries}
        pageId={props.pageId} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};
