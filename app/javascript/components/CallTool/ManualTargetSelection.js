// @flow
import React, { Component } from 'react';

type Props = {
  enabled?: boolean,
  targets: Target[], // list of targets
  target: ?Target, // selected target
  onChange: (target: Target) => void,
};

type State = {};

export default class ManualTargetSelection extends Component<*, Props, State> {
  render() {
    if (!this.props.enabled) return null;
    return (
      <div>
        <h3>Manual target selection</h3>
        <p>**Drill Down Targetting** if `manualTargetSelection`</p>
      </div>
    );
  }
}
