import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import ComponentWrapper from '../components/ComponentWrapper';
import EmailPensionView from '../plugins/email_pension/EmailPensionView';
import EmailRepresentativeView from '../plugins/email_pension/EmailRepresentativeView';

const store = window.champaign.store;

window.mountEmailPension = (root, props, targetEndpoint) => {
  const el = document.getElementById(root);
  if (!el) return;

  const camelizedProps = camelizeKeys(props);

  store.dispatch({ type: 'email_target:initialize', payload: camelizedProps });
  render(
    <ComponentWrapper store={store} locale={props.locale}>
      {targetEndpoint === '' ? (
        <EmailPensionView {...camelizedProps} />
      ) : (
        <EmailRepresentativeView {...camelizedProps} />
      )}
    </ComponentWrapper>,
    el
  );
};
