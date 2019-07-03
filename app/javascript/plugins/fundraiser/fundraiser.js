import React from 'react';
import { render } from 'react-dom';
import queryString from 'query-string';
import ComponentWrapper from '../components/ComponentWrapper';
import FundraiserView from '../plugins/fundraiser/FundraiserView';
import configureStore from '../state';

const store = window.champaign.store;

function mount(root, options, Component = FundraiserView) {
  const el = document.getElementById(root);
  if (el) {
    render(
      <ComponentWrapper
        store={options.store}
        locale={options.locale}
        optimizelyHook={window.optimizelyHook}
      >
        <FundraiserView />
      </ComponentWrapper>,
      el
    );
  }
}

window.mountFundraiser = function(root, data) {
  const search = queryString.parse(location.search, {
    arrayFormat: 'bracket',
  });
  const { personalization, page } = window.champaign;
  store.dispatch({
    type: 'initialize_fundraiser',
    payload: data.fundraiser,
    skip_log: true,
  });
  store.dispatch({
    type: 'set_donation_bands',
    payload: data.fundraiser.donationBands,
    skip_log: true,
  });

  store.dispatch({
    type: 'change_currency',
    payload: search.currency || data.fundraiser.currency,
    skip_log: true,
  });

  const amount = parseInt(search.amount, 10) || undefined;
  store.dispatch({ type: 'change_amount', payload: amount, skip_log: true });

  const preselect = search.preselect === '1' || data.fundraiser.preselectAmount;
  store.dispatch({
    type: 'preselect_amount',
    payload: preselect,
    skip_log: true,
  });

  const rDefault = search.recurring_default || data.fundraiser.recurringDefault;
  store.dispatch({
    type: 'set_recurring_defaults',
    payload: rDefault,
    skip_log: true,
  });

  store.dispatch({
    type: 'set_direct_debit_only',
    payload: search.dd_only === '1',
    skip_log: true,
  });

  store.dispatch({
    type: 'search_string_overrides',
    payload: search,
    skip_log: true,
  });

  const options = { store, locale: data.locale };

  mount(root, options, FundraiserView);

  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../plugins/fundraiser/FundraiserView', () => {
      mount(
        root,
        options,
        require('../plugins/fundraiser/FundraiserView').default
      );
    });
  }
};
