// @flow
import React from 'react';
import Button from '../../components/Button/Button';
import WelcomeMember from '../../components/WelcomeMember/WelcomeMember';
import type { Member } from '../../state';

type Props = {
  member: Member,
  onResetMember: () => void,
  onSubmit: () => void,
  config: any,
};
export function PetitionComponent(props: Props) {
  const { member, config } = props;
  return (
    <div className="PetitionComponent">
      {props.member && (
        <WelcomeMember
          member={props.member}
          resetMember={props.onResetMember}
        />
      )}
      {!props.member && <p>Form goes here</p>}
      <Button>Sign Petition</Button>
    </div>
  );
}
