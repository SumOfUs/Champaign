/* @flow */
import React, { Component } from 'react';
import classnames from 'classnames';

export type Props = {
  onClick?: () => void,
  active: boolean,
  complete: boolean,
  index: number,
  label: string,
};

export default class Step extends Component {
  props: Props;

  render() {
    const { active, complete, index, label } = this.props;
    const rootClasses = classnames({
      'Step-root': true,
      active,
      complete,
    });

    return (
      <div className={rootClasses} onClick={this.props.onClick}>
        <div className="Step-circle">
          <span>{ index + 1 }</span>
        </div>
        <div className="Step-label">{label}</div>
      </div>
    );
  }
}
