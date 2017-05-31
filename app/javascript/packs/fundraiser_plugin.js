// @flow
import React from 'react';
import { render } from 'react-dom';
import FundraiserView from '../fundraiser/FundraiserView';
import type { AppState } from '../state/reducers';

const store: Store<AppState, any> = window.champaignStore;

window.document.addEventListener('DOMContentLoaded', () => {
  render(
    <ComponentWrapper store={store} locale={initialState['locale']}>
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById('fundraiser-component')
  );
});

