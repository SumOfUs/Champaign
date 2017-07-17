// @flow
import React from 'react';
import classnames from 'classnames';
import './Button.scss';

import type { Element } from 'react';

type Props = {
  type?: string,
  disabled?: boolean,
  className?: string,
  onClick?: (e: SyntheticEvent) => any,
  children?: Element<any>,
};

const Button = (props: Props) => {
  const className = classnames(
    'Button-root',
    props.disabled ? 'disabled' : '',
    props.className ? props.className : ''
  );
  return (
    <button
      disabled={props.disabled}
      type={props.type || 'text'}
      className={className}
      onClick={props.disabled ? null : props.onClick}
    >
      {props.children}
    </button>
  );
};

export default Button;
