/* @flow */
import React, { Component } from 'react';
import Step from './Step';

type Props = {
  steps: string[],
  currentStep: number,
  title: string,
  changeStep: (step: number) => void,
};

export default class Stepper extends Component<Props> {
  changeStep(index: number) {
    if (this.props.currentStep > index) {
      this.props.changeStep(index);
    }
  }

  renderStep(step: string, index: number) {
    const { currentStep } = this.props;
    return (
      <Step
        key={index}
        index={index}
        label={step}
        active={currentStep === index}
        complete={currentStep > index}
        onClick={() => this.changeStep(index)}
      />
    );
  }

  render() {
    return (
      <div className="Stepper fundraiser-bar__top">
        <h2 className="Stepper__header">{this.props.title}</h2>
        <div className="Stepper__steps">
          <hr className="Stepper__line" />
          {this.props.steps.map((step, index) => this.renderStep(step, index))}
        </div>
      </div>
    );
  }
}
