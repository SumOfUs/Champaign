// @flow
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import Button from '../../components/Button/Button';
import WelcomeMember from '../../components/WelcomeMember/WelcomeMember';
import { resetMember } from '../../state/member/reducer';

import type { Member } from '../../state';

type Props = {
  config: any,
  resetMember: () => void,
  onSubmit: () => void,
};

export function PetitionComponent(props: Props) {
  const dispatch = useDispatch();
  const { member } = useSelector(state => state);

  return (
    <div className="PetitionComponent">
      <WelcomeMember member={member} resetMember={props.resetMember} />
      {!member && <p>Form goes here</p>}
      <Button onClick={props.onSubmit}>Sign Petition</Button>
    </div>
  );
}
