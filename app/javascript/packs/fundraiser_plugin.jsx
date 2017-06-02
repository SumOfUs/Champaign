// @flow
import React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';
import FundraiserView from '../fundraiser/FundraiserView';
import configureStore from '../state';
import type { AppState } from '../state/reducers';

const store = configureStore({});

window.document.addEventListener('DOMContentLoaded', initialState => {
  render(
    <ComponentWrapper store={store} locale={initialState['locale']}>
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById('fundraiser-component')
  );
});
