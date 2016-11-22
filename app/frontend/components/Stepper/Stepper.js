/* @flow */
import React, { Component } from 'react';
import Step from './Step';

type Props = {
  steps: string[];
  currentStep: number;
  title: string;
  changeStep: (step: number) => void;
};

export default class Stepper extends Component {
  props: Props;

  changeStep(index: number) {
    if (this.props.currentStep > index) {
      this.props.changeStep(index);
    }
  }

  render() {
    return (
      <div className="Stepper-wrapper fundraiser-bar__top">
        <h2>{ this.props.title }</h2>
        <div className="Stepper-root">
          <hr className="Stepper-line" />
          {this.props.steps.map((step, index) =>
            <Step
              key={index}
              index={index}
              label={step}
              active={this.props.currentStep === index}
              complete={this.props.currentStep > index}
              onClick={() => this.changeStep(index)}
            />
          )}
        </div>
      </div>
    );
  }
}
