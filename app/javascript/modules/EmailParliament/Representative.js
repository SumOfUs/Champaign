import React from 'react';
import ProfilePicture from '../../components/ProfilePicture';
import './Representative.css';

const Target = props => (
  <div className="Representative-copy">
    <span className="Representative-name">
      {props.title} {props.firstName} {props.surname}
    </span>
    <span className="Representative-party">{props.partyAffiliation}</span>
  </div>
);

export default props => {
  const { targets } = props;

  if (!targets) return null;

  const items = targets.map(target => <Target {...target} />);

  return <div className="Representative">{items}</div>;
};
