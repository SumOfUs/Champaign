/*  */
import React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';
import CallToolAnalyticsView from '../plugins/call_tool_analytics/CallToolAnalyticsView';

function mountCallToolAnalytics(root, props) {
  const el = document.getElementById(root);
  if (!el) return;
  render(
    <ComponentWrapper locale="en">
      <CallToolAnalyticsView {...props} />
    </ComponentWrapper>,
    el
  );
}

window.mountCallToolAnalytics = mountCallToolAnalytics;
