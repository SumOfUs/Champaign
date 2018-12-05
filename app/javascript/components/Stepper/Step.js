/* @flow */
import React, { Component } from 'react';
import classnames from 'classnames';
import './Step.scss';

export type Props = {
  onClick?: () => void,
  active: boolean,
  complete: boolean,
  index: number,
  label: string,
};

export default class Step extends Component<Props> {
  render() {
    const { active, complete, index, label } = this.props;
    const rootClasses = classnames({
      Step: true,
      'Step--active': active,
      'Step--complete': complete,
    });

    return (
      <div className={rootClasses} onClick={this.props.onClick}>
        <div className="Step__circle">
          <span>{index + 1}</span>
        </div>
        <div className="Step__label">{label}</div>
      </div>
    );
  }
}
