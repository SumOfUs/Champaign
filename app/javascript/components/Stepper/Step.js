/*  */
import React, { Component } from 'react';
import classnames from 'classnames';
import { FormattedMessage } from 'react-intl';
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
          <FormattedMessage
            id={`fundraiser.donation_steps.number${index + 1}`}
            defaultMessage={index + 1}
          />
        </div>
        <div className="Step__label">{label}</div>
      </div>
    );
  }
}
