import React from 'react';
import classnames from 'classnames';
import './Button.scss';

const Button = props => {
  const className = classnames(
    'Button-root',
    props.disabled ? 'disabled' : '',
    props.className ? props.className : ''
  );
  return (
    <button
      disabled={props.disabled}
      type={props.type}
      name={props.name}
      id={props.id}
      className={className}
      onClick={props.disabled ? null : props.onClick}
    >
      {props.children}
    </button>
  );
};

export default Button;
