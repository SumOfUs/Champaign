import { omit, pick } from 'lodash';
import * as React from 'react';
import { render } from 'react-dom';
import { Store } from 'redux';
import URI from 'urijs';
import ComponentWrapper from '../../components/ComponentWrapper';
import { IAppState } from '../../types';
import { camelizeKeys } from '../../util/util';
import Plugin from '../plugin';
import CallToolView from './CallToolView';

interface ICallToolOptions {
  el: HTMLElement;
  namespace: string;
  config: any; // todo
  store: Store<IAppState>;
}

const parseFilters = function(params) {
  if (!!params.filters) {
    return params.filters;
  }
  const filters = {};
  for (const key in params) {
    if (key.indexOf('filters_') === 0 || key.indexOf('filter_') === 0) {
      const shortKey = key.replace(/filters?_/i, '');
      filters[shortKey] = params[key];
    }
  }
  return filters;
};

export const init = options => {
  if (!options.el) {
    options.el = document.getElementById('call-tool-component');
  }
  const { el, store } = options;
  const countryCode = window.champaign.personalization.member.country;
  const filters = parseFilters(window.champaign.personalization.urlParams);
  const trackingParams = pick(
    window.champaign.personalization.urlParams,
    'source',
    'akid',
    'referring_akid',
    'referrer_id',
    'rid'
  );
  return new CallTool({
    config: {
      ...options.config,
      countryCode,
      ...filters,
      trackingParams,
      onSuccess(target) {
        window.location.href = URI(window.champaign.page.follow_up_url)
          .addQuery({
            'target[name]': target.name,
            'target[title]': target.title,
          })
          .toString();
      },
    },
    el,
    namespace: 'calltool',
    store,
  });
};

class CallTool extends Plugin<any> {
  public store: Store<IAppState>;
  public customRenderer: (instance: CallTool) => any | undefined;
  public wrappedReactComponent?: React.Component;

  constructor(options: ICallToolOptions) {
    super(options);
    this.store = options.store;
    this.render();
  }

  public render() {
    if (this.customRenderer) {
      return this.customRenderer(this);
    }
    const props = omit(camelizeKeys(this.config), 'id', 'ref');

    return render(
      <ComponentWrapper store={this.store} locale={window.I18n.locale}>
        <CallToolView {...props} />
      </ComponentWrapper>,
      this.el
    );
  }
}
