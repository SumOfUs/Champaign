import React, { Component, Children } from 'react';
import classnames from 'classnames';

type OwnProps = {
  visible: boolean;
  children: ReactChildren;
};

export default class StepContent extends Component {
  props: OwnProps;

  render() {
    const { children, visible } = this.props;
    const className = classnames({
      StepContent: true,
      'StepContent-hidden': !visible,
    });
    return (
      <div className={className}>
        {Children.only(children)}
      </div>
    );
  }
}
