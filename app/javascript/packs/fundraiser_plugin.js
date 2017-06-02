// @flow
import React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';
import FundraiserView from '../fundraiser/FundraiserView';
import type { AppState } from '../state/reducers';

const store = window.champaignStore;

window.document.addEventListener('DOMContentLoaded', () => {
  render(
    <ComponentWrapper store={store} locale={initialState['locale']}>
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById('fundraiser-component')
  );
});
