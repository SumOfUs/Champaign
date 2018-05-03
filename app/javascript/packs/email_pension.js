// @flow
import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import ComponentWrapper from '../components/ComponentWrapper';
import EmailPensionView from '../email_pension/EmailPensionView';
import type { AppState } from '../state/reducers';

type emailPensionInitialState = {
  locale: string,
  emailSubject?: string,
  country?: string,
  emailBody?: string,
  emailHeader?: string,
  emailFooter?: string,
  email?: string,
  name?: string,
  pageId: string | number,
  isSubmitting: boolean,
};

const store: Store<AppState, *> = window.champaign.store;

window.mountEmailPension = (root: string, props: emailPensionInitialState) => {
  props = camelizeKeys(props);
  store.dispatch({ type: 'email_target:initialize', payload: props });

  render(
    <ComponentWrapper store={store} locale={props.locale}>
      <EmailPensionView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};
