import React from 'react';
import classnames from 'classnames';
import './FormGroup.scss';

export default function FormGroup(props) {
  const className = classnames('FormGroup', 'form__group', props.className);
  return <div className={className}>{props.children}</div>;
}
