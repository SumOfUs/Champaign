// @flow
import React from 'react';
import classnames from 'classnames';
import './FormGroup.scss';

type Props = {
  className?: string,
  children: React$Element<any>,
};

export default function FormGroup(props: Props): React$Element<any> {
  const className = classnames('FormGroup', 'form__group', props.className);
  return <div className={className}>{props.children}</div>;
}
