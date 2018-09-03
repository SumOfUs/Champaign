// @flow
import React from 'react';
import { render } from 'react-dom';
import queryString from 'query-string';
import ComponentWrapper from '../components/ComponentWrapper';
import FundraiserView from '../fundraiser/FundraiserView';
import configureStore from '../state';

import type { AppState } from '../state/reducers';
import type { DonationBands } from '../state/fundraiser/types.js';
import type { InitialAction } from '../state/reducers';
import type {
  FundraiserAction,
  FundraiserInitializationOptions,
} from '../state/fundraiser/types';

type SearchParams = {
  amount?: string,
  currency?: string,
  dd_only?: string,
  recurring_default?: string,
  preselect?: string,
  hide_spm?: string, // hide saved payment methods
};

type Action = FundraiserAction | InitialAction;
const store: Store<AppState, FundraiserAction> = window.champaign.store;
const dispatch = (a: Action): Action => store.dispatch(a);

type MountFundraiserOptions = ChampaignPersonalizationData & {
  fundraiser: FundraiserInitializationOptions,
};

function mount(root: string, options: any, Component?: any = FundraiserView) {
  render(
    <ComponentWrapper
      store={options.store}
      locale={options.locale}
      optimizelyHook={window.optimizelyHook}
    >
      <FundraiserView />
    </ComponentWrapper>,
    document.getElementById(root)
  );
}

window.mountFundraiser = function(root: string, data: MountFundraiserOptions) {
  const search: SearchParams = queryString.parse(location.search, {
    arrayFormat: 'bracket',
  });
  const { personalization, page } = window.champaign;
  dispatch({
    type: 'initialize_fundraiser',
    payload: data.fundraiser,
    skip_log: true,
  });
  dispatch({
    type: 'set_donation_bands',
    payload: data.fundraiser.donationBands,
    skip_log: true,
  });

  dispatch({
    type: 'toggle_direct_debit',
    payload: data.fundraiser.showDirectDebit,
    skip_log: true,
  });

  dispatch({
    type: 'change_currency',
    payload: search.currency || data.fundraiser.currency,
    skip_log: true,
  });

  const amount = parseInt(search.amount, 10) || undefined;
  dispatch({ type: 'change_amount', payload: amount, skip_log: true });

  const preselect = search.preselect === '1' || data.fundraiser.preselectAmount;
  dispatch({ type: 'preselect_amount', payload: preselect, skip_log: true });

  const rDefault = search.recurring_default || data.fundraiser.recurringDefault;
  dispatch({
    type: 'set_recurring_defaults',
    payload: rDefault,
    skip_log: true,
  });

  dispatch({
    type: 'set_direct_debit_only',
    payload: search.dd_only === '1',
    skip_log: true,
  });
  dispatch({
    type: 'search_string_overrides',
    payload: search,
    skip_log: true,
  });

  const options = { store, locale: data.locale };

  mount(root, options, FundraiserView);

  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../fundraiser/FundraiserView', () => {
      mount(root, options, require('../fundraiser/FundraiserView').default);
    });
  }
};
