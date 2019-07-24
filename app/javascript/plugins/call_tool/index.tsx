import { omit, pick } from 'lodash';
import * as React from 'react';
import { render } from 'react-dom';
import { Store } from 'redux';
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
export const init = options => {
  if (!options.el) {
    options.el = document.getElementById('call-tool-component');
  }
  const { el, config, store } = options;
  const member = window.champaign.personalization.member;
  const memberData = pick(member, 'name', 'email', 'country', 'postal');
  const formValues = window.champaign.personalization.formValues;
  return new CallTool({
    config: {
      ...config,
      ...memberData,
      ...formValues,
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
