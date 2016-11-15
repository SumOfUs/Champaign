/* @flow */
import React from 'react';
import classnames from 'classnames';
import './Button.css';

type Props = {
  disabled?: boolean;
  className?: string,
  onClick?: () => void,
  children?: mixed,
};

const Button = (props: Props) => {
  const className = classnames(
    'Button-root',
    (props.disabled ? 'disabled' : ''),
    (props.className ? props.className : ''),
  );
  return (
    <div className={className}
         onClick={props.disabled ? null : props.onClick}>
      {props.children}
    </div>
  );
}

export default Button;
