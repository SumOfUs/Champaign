// @flow
import React from 'react';
import { FormattedMessage } from 'react-intl';

type Props = {
  target: ?Target,
};

export default function SelectedTarget(props: Props) {
  if (!props.target) return null;

  const { name, title } = props.target;

  return (
    <div className="SelectedTarget">
      <p>
        <FormattedMessage id="call_tool.you_will_be_calling" />
        <span className="SelectedTarget-name">
          {name}
        </span>
        {title &&
          <span>
            {', '}
            {title}
            {'.'}
          </span>}
      </p>
    </div>
  );
}
