// @flow
import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import ComponentWrapper from '../components/ComponentWrapper';
import CallToolView from '../call_tool/CallToolView';

window.mountCallTool = (root: string, props: any) => {
  props = camelizeKeys(props);

  render(
    <ComponentWrapper
      locale={props.locale}
      optimizelyHook={window.optimizelyHook}
    >
      <CallToolView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};
