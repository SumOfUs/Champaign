// @flow
import React, { Component, Children, cloneElement } from 'react';
import Stepper from './Stepper';
import ShowIf from '../ShowIf';
import compact from 'lodash/compact';
import './Stepper.scss';

type OwnProps = {
  changeStep: (step: number) => void;
  currentStep: number;
  submitting: boolean;
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

  normalState() {
    return (
      <div className="StepWrapper-root">
        <div className="overlay-toggle__mobile-ui">
          <a className="overlay-toggle__close-button">&#x2715;</a>
        </div>
        <Stepper
          steps={this.getTitles()}
          {...this.props}
        />
        <div className="fundraiser-bar__main">
          {this.childrenWithExtraProps(this.props.children)}
        </div>
      </div>
    );
  }

  submissionState() {
    return (
      <div className="submission-interstitial">
        <h1 className="submission-interstitial__title"><i className="fa fa-spin fa-cog"></i>Processing</h1>
        <h4>Please do not close this tab<br />or use the back button.</h4>
      </div>
    );
  }

  render() {
    return (
      <div>
        <ShowIf condition={!this.props.submitting}>
          { this.normalState() }
        </ShowIf>
        <ShowIf condition={this.props.submitting}>
          {this.submissionState() }
        </ShowIf>
      </div>
    );
  }
}
