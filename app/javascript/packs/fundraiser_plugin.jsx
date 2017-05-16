import 'babel-polyfill';
import React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';
import FundraiserView from '../fundraiser/FundraiserView';
import configureStore from '../state';

const store = window.champaignStore;

window.mountFundraiser = function(root, data) {
  store.dispatch({ type: 'initialize_page', payload: window.champaign.page });
  store.dispatch({ type: 'parse_champaign_data', payload: data });
  render(
    <ComponentWrapper store={store} locale={data.locale}>
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById(data.el)
  );
};
