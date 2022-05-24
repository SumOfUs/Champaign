import React, { Component, Children, cloneElement } from 'react';
import Stepper from './Stepper';
import ShowIf from '../ShowIf';
import { FormattedMessage } from 'react-intl';
import _ from 'lodash';
import './Stepper.scss';

export default class StepWrapper extends Component {
  constructor(props) {
    super(props);
    this.state = {
      steps: [],
    };
  }

  getTitles() {
    const { children } = this.props;
    if (!children) return [];
    return Children.map(_.compact(children), child => child.props.title);
  }

  childrenWithExtraProps(children) {
    return Children.map(_.compact(children), (child, index) =>
      cloneElement(child, { visible: index === this.props.currentStep })
    );
  }

  normalState() {
    const stepperProps = {
      ...this.props,
      steps: this.getTitles(),
    };
    return (
      <div className="StepWrapper-root">
        <div className="overlay-toggle__mobile-ui">
          <a className="overlay-toggle__close-button">✕</a>
        </div>
        <Stepper {...stepperProps} />
        <div className="fundraiser-bar__main">
          {this.childrenWithExtraProps(this.props.children)}
        </div>
      </div>
    );
  }

  submissionState() {
    return (
      <div className="submission-interstitial">
        <h1 className="submission-interstitial__title">
          <i className="fa fa-spin fa-cog" />
          <FormattedMessage id="form.processing" />
        </h1>
        <h4>
          <FormattedMessage id="form.do_not_close" />
        </h4>
      </div>
    );
  }

  render() {
    return (
      <div>
        <ShowIf condition={!this.props.submitting}>{this.normalState()}</ShowIf>
        <ShowIf condition={this.props.submitting}>
          {this.submissionState()}
        </ShowIf>
      </div>
    );
  }
}
