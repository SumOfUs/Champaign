import React from 'react';
import { FormattedMessage } from 'react-intl';
import './SelectedTarget.css';

export default function SelectedTarget(props) {
  if (!props.target) return null;

  const { name, title } = props.target;

  return (
    <p className="SelectedTarget">
      <FormattedMessage id="call_tool.you_will_be_calling" />
      <span className="SelectedTarget__name">{name}</span>
      {title && <span>, {title}.</span>}
    </p>
  );
}
