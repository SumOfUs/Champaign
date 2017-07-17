// @flow
import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import Wrapper from '../components/ComponentWrapper';
import CallToolView from '../call_tool/CallToolView';

function mount(root, props, Component = CallToolView) {
  render(
    <Wrapper locale={props.locale} optimizelyHook={window.optimizelyHook}>
      <Component {...props} />
    </Wrapper>,
    document.getElementById(root)
  );
}

window.mountCallTool = (root: string, props: any) => {
  props = camelizeKeys(props);

  mount(root, props);

  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../call_tool/CallToolView', () => {
      console.log('new module:', require('../call_tool/CallToolView').default);
      mount(root, props, require('../call_tool/CallToolView').default);
    });
  }
};
