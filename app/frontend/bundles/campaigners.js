/* @flow */
import React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';
import CallToolAnalyticsView   from '../containers/CallToolAnalyticsView/CallToolAnalyticsView';

type callToolAnalyticsProps = {
  pageId: string | number;
}

window.mountCallToolAnalytics = (root: string, props: callToolAnalyticsProps) => {
  render(
    <ComponentWrapper locale='en'>
      <CallToolAnalyticsView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};
