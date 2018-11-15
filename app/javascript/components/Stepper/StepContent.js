import React, { Component, Children } from 'react';
import classnames from 'classnames';

type Props = {
  visible: boolean,
  children: ReactChildren,
};

export default class StepContent extends Component<Props> {
  render() {
    const { children, visible } = this.props;
    const className = classnames({
      StepContent: true,
      'StepContent-hidden': !visible,
    });
    return <div className={className}>{Children.only(children)}</div>;
  }
}
