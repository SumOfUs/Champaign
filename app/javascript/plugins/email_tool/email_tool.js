import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import ComponentWrapper from '../components/ComponentWrapper';
import EmailToolView from '../plugins/email_tool/EmailToolView';

function mount(root, props, Component = EmailToolView) {
  const { locale, ...emailProps } = props;
  const el = document.getElementById(root);
  if (!el) return;
  render(
    <ComponentWrapper locale={props.locale}>
      <Component {...camelizeKeys(emailProps)} />
    </ComponentWrapper>,
    el
  );
}

window.mountEmailTool = (root, props) => {
  mount(root, props, EmailToolView);
  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../plugins/email_tool/EmailToolView', () => {
      mount(
        root,
        props,
        require('../plugins/email_tool/EmailToolView').default
      );
    });
  }
};
