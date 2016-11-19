import React, { Component, Children } from 'react';

type OwnProps = {
  visible: boolean;
  children: ReactChildren;
};

export default class StepContent extends Component {
  props: OwnProps;

  render() {
    const { children, visible } = this.props;

    if (!visible) return null;

    return (
      <div className="StepContent-root">
        {Children.only(children)}
      </div>
    );
  }
}
