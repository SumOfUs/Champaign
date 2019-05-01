// @flow
import React from 'react';
import ProfilePicture from '../../components/ProfilePicture';
import type { Target } from './index';
import './Representative.css';

type Props = {
  target?: Target,
};

export default (props: Props) => {
  const { target } = props;
  if (!target) return null;
  return (
    <div className="Representative">
      <ProfilePicture
        src={target.picture}
        alt={`Profile picture of ${target.displayAs}`}
      />
      <div className="Representative-copy">
        <span className="Representative-name">{target.displayAs} </span>
        <span className="Representative-party">{target.party}</span>
      </div>
    </div>
  );
};
