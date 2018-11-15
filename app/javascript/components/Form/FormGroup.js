// @flow
import React from 'react';
import classnames from 'classnames';
import type { Element } from 'react';
import './FormGroup.scss';

type Props = {
  className?: string,
  children: any,
};

export default function FormGroup(props: Props): React$Element<any> {
  const className = classnames('FormGroup', 'form__group', props.className);
  return <div className={className}>{props.children}</div>;
}
