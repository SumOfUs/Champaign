import * as qs from 'query-string';
import { IFundraiserPluginConfig } from '../../window';

export const configureStore = (data, dispatch) => {
  const search = qs.parse(location.search, {
    arrayFormat: 'bracket',
  });
  const { personalization, page } = window.champaign;
  dispatch({
    type: 'initialize_fundraiser',
    payload: data,
    skip_log: true,
  });
  dispatch({
    type: 'set_donation_bands',
    payload: data.donationBands,
    skip_log: true,
  });

  dispatch({
    type: 'change_currency',
    payload: search.currency || data.currency,
    skip_log: true,
  });

  const amount = parseInt(search.amount as string, 10) || undefined;
  dispatch({ type: 'change_amount', payload: amount, skip_log: true });

  const preselect = search.preselect === '1' || data.preselectAmount;
  dispatch({
    type: 'preselect_amount',
    payload: preselect,
    skip_log: true,
  });

  const rDefault = search.recurring_default || data.recurringDefault;
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
};

export const fundraiserData = (config: IFundraiserPluginConfig) => {
  const {
    member,
    location,
    paymentMethods,
    donationBands,
    outstandingFields,
  } = window.champaign.personalization;

  return {
    pageId: window.champaign.page.id,
    currency: location.currency,
    member,
    paymentMethods,
    donationBands,
    outstandingFields,
    formId: config.form_id,
    // title: <get title from template, fallback to: config.title>,
    title: config.title,
    preselectAmount: config.preselect_amount,
    fields: config.fields,
    recurringDefault: config.recurring_default,
    // oneClick: <get this from template>,
    // freestanding: <get this from template>
  };
};
