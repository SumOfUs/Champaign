/* @flow */
import React from 'react';
import { render } from 'react-dom';
import { addLocaleData } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import esLocaleData from 'react-intl/locale-data/es';

import configureStore from './state';
import { camelizeKeys } from './util/util';
import ComponentWrapper from './ComponentWrapper';
import FundraiserView from './containers/FundraiserView/FundraiserView';
import CallToolView   from './containers/CallToolView/CallToolView';
import EmailTargetView   from './containers/EmailTargetView/EmailTargetView';

import type { Store } from 'redux';
import type { AppState } from './state/reducers';

import './components.css';

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);

const store: Store<AppState, *> = configureStore({});

window.mountFundraiser = (root: string, initialState?: any = {})  => {
  store.dispatch({ type: 'initialize_page', payload: window.champaign.page });
  store.dispatch({ type: 'parse_champaign_data', payload: initialState });

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

type callToolProps = {
  locale: string;
  title?: string;
  targets: any[];
  targetCountries: any[];
  countriesPhoneCodes: any[];
  pageId: string | number;
  targetByCountryEnabled: boolean;
};

window.mountCallTool = (root: string, props: callToolProps) => {
  props = camelizeKeys(props);

  render(
    <ComponentWrapper locale={props.locale}>
      <CallToolView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};

type emailTargetInitialState = {
  locale: string;
  emailSubject?: string;
  emailBody?: string;
  email: string;
  name: string;
  pageId: string | number;
  isSubmitting: boolean;
};

window.mountEmailTarget = (root: string, props: emailTargetInitialState) => {
  props = camelizeKeys(props);

  store.dispatch({ type: 'email_target:initialize', payload: props});

  render(
    <ComponentWrapper store={store} locale={props.locale}>
      <EmailTargetView />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};
