// @flow
import React, { Component, Children, cloneElement } from 'react';
import Stepper from './Stepper';
import compact from 'lodash/compact';
import './Stepper.scss';

type OwnProps = {
  changeStep: (step: number) => void;
  currentStep: number;
  title: string;
  children?: any;
};

export default class StepWrapper extends Component {
  props: OwnProps;
  state: {
    steps: string[];
  };

  constructor(props: OwnProps) {
    super(props);
    this.state = {
      steps: [],
    };
  }

  getTitles() {
    const { children } = this.props;
    return Children.map(compact(children), child => child.props.title);
  }

  childrenWithExtraProps(children: any) {
    return Children.map(compact(children), (child, index) =>
      cloneElement(child, { visible: index === this.props.currentStep })
    );
  }

  render() {
    const { currentStep, changeStep, children } = this.props;
    return (
      <div className="StepWrapper-root">
        <Stepper
          steps={this.getTitles()}
          {...this.props}
        />
        <div className="fundraiser-bar__main">
          {this.childrenWithExtraProps(children)}
        </div>
      </div>
    );
  }
}
