import React, { Component, Children } from 'react';

type OwnProps = {
  title: string;
  visible: boolean;
  children: ReactChildren;
};

export default class StepWrapper extends Component {
  props: OwnProps;

  render() {
    const { currentStep, children, visible } = this.props;

    if (!visible) return null;

    return (
      <div className="StepContent-root">
        {Children.only(children)}
      </div>
    );
  }
}
