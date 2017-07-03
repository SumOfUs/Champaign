import 'babel-polyfill';
import React from 'react';
import { render } from 'react-dom';
import queryString from 'query-string';
import ComponentWrapper from '../components/ComponentWrapper';
import FundraiserView from '../fundraiser/FundraiserView';
import configureStore from '../state';

const store = window.champaign.store;

window.mountFundraiser = function(root, data) {
  store.dispatch({ type: 'initialize_page', payload: window.champaign.page });
  store.dispatch({ type: 'parse_champaign_data', payload: data });
  store.dispatch({
    type: 'querystring_parameters',
    payload: queryString.parse(location.search),
  });
  render(
    <ComponentWrapper store={store} locale={data.locale}>
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById(data.el)
  );
};
