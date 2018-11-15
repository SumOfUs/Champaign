// @flow
import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import Wrapper from '../components/ComponentWrapper';
import CallToolView from '../call_tool/CallToolView';

function mount(root, props, Component = CallToolView) {
  const el = document.getElementById(root);
  if (!el) return;
  render(
    <Wrapper locale={props.locale} optimizelyHook={window.optimizelyHook}>
      <Component {...props} />
    </Wrapper>,
    el
  );
}

window.mountCallTool = (root: string, props: any) => {
  props = camelizeKeys(props);

  mount(root, props);

  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../call_tool/CallToolView', () => {
      mount(root, props, require('../call_tool/CallToolView').default);
    });
  }
};
