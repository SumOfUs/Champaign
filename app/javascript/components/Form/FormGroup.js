import React from 'react';
import classnames from 'classnames';

type Props = {
  className?: string,
  style?: CSSProperties,
  children: React$Element<any>,
};

export default function FormGroup(props: Props): React$Element<any> {
  const className = classnames('form__group', props.className);
  return (
    <div className={className} style={props.style}>
      {props.children}
    </div>
  );
}
