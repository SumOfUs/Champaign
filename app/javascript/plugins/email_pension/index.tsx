import { omit, pick } from 'lodash';
import * as React from 'react';
import { render } from 'react-dom';
import { Store } from 'redux';
import ComponentWrapper from '../../components/ComponentWrapper';
import { IAppState } from '../../types';
import { camelizeKeys } from '../../util/util';
import Plugin from '../plugin';
import EmailPensionView from './EmailPensionView';
import EmailRepresentativeView from './EmailRepresentativeView';

interface IEmailPensionOptions {
  el: HTMLElement;
  namespace: string;
  config: any; // todo
  store: Store<IAppState>;
}
export const init = options => {
  if (!options.el) {
    options.el = document.getElementById('email-pension-component');
  }
  const { el, config, store } = options;
  const member = window.champaign.personalization.member;
  const memberData = pick(member, 'name', 'email', 'country', 'postal');
  const formValues = window.champaign.personalization.formValues;
  return new EmailPension({
    config: {
      ...config,
      ...memberData,
      ...formValues,
    },
    el,
    namespace: 'emailpension',
    store,
  });
};

class EmailPension extends Plugin<any> {
  public store: Store<IAppState>;
  public customRenderer: (instance: EmailPension) => any | undefined;
  public wrappedReactComponent?: React.Component;

  constructor(options: IEmailPensionOptions) {
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
        {props.targetEndpoint && <EmailRepresentativeView {...props} />}
        {!props.targetEndpoint && <EmailPensionView {...props} />}
      </ComponentWrapper>,
      this.el
    );
  }
}
