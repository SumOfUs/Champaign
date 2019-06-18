// @flow
import React from 'react';
import Button from '../../components/Button/Button';

export function PetitionComponent(props: any) {
  console.log('rendering PetitionComponent', props.date);
  return (
    <div className="PetitionComponent">
      <h3>Petition Form</h3>
      <p>{props.date}</p>
      <Button>Sign Petition</Button>
    </div>
  );
}
