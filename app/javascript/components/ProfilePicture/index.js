import React from 'react';
import classnames from 'classnames';
import './ProfilePicture.css';

export default props => {
  if (!props.src) return null;
  const classNames = classnames('ProfilePicture', props.className);

  return <img className={classNames} src={props.src} alt={props.alt} />;
};
