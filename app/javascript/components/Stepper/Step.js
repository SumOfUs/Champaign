/*  */
import React, { Component } from 'react';
import classnames from 'classnames';
import './Step.scss';

export default class Step extends Component {
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
