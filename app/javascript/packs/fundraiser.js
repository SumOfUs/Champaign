// @flow
import React from 'react';
import { render } from 'react-dom';
import queryString from 'query-string';
import ComponentWrapper from '../components/ComponentWrapper';
import FundraiserView from '../fundraiser/FundraiserView';
import configureStore from '../state';

import type { AppState } from '../state/reducers';
import type { DonationBands } from '../state/fundraiser/types.js';
import type { PageAction } from '../state/page/reducer';
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
};

type Action = FundraiserAction | PageAction | InitialAction;
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
  const search: SearchParams = queryString.parse(location.search);
  const { personalization, page } = window.champaign;
  dispatch({ type: 'parse_champaign_data', payload: personalization });
  dispatch({ type: 'initialize_page', payload: page });
  dispatch({ type: 'initialize_fundraiser', payload: data.fundraiser });
  dispatch({
    type: 'set_donation_bands',
    payload: data.fundraiser.donationBands,
  });

  dispatch({
    type: 'toggle_direct_debit',
    payload: data.fundraiser.showDirectDebit,
  });

  dispatch({
    type: 'change_currency',
    payload: search.currency || data.fundraiser.currency,
  });

  const amount = parseInt(search.amount, 10) || undefined;
  dispatch({ type: 'change_amount', payload: amount });

  const preselect = search.preselect === '1' || data.fundraiser.preselectAmount;
  dispatch({ type: 'preselect_amount', payload: preselect });

  const rDefault = search.recurring_default || data.fundraiser.recurringDefault;
  dispatch({ type: 'set_recurring_defaults', payload: rDefault });

  dispatch({ type: 'set_direct_debit_only', payload: search.dd_only === '1' });

  const options = { store, locale: data.locale };

  mount(root, options, FundraiserView);

  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../fundraiser/FundraiserView', () => {
      mount(root, options, require('../fundraiser/FundraiserView').default);
    });
  }
};
