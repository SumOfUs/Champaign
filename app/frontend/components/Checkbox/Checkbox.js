// @flow
import React from 'react';
import type { Element } from 'react';
import classnames from 'classnames';

import './Checkbox.scss';

type OwnProps = {
  className?: string;
  disabled?: boolean;
  defaultChecked?: boolean;
  children?: Element<any>;
  onChange: (e: SyntheticInputEvent) => void;
};

export default function Checkbox({ className, disabled, defaultChecked, onChange, children }: OwnProps) {
  return (
    <div className={classnames('Checkbox', className)}>
      <label className="Checkbox__label">
        <input type="checkbox" disabled={disabled} defaultChecked={defaultChecked} onChange={onChange} />
        {children}
      </label>
    </div>
  );
}
