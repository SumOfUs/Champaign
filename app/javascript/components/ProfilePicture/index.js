// @flow
import React from 'react';
import classnames from 'classnames';
import './ProfilePicture.css';

type Props = {
  src: string,
  alt: string,
  className?: string,
};

export default (props: Props) => {
  if (!props.src) return null;
  const classNames = classnames('ProfilePicture', props.className);

  return <img className={classNames} src={props.src} alt={props.alt} />;
};
