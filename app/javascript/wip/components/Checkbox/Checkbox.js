// @flow
import React from 'react';
import type { Element } from 'react';
import classnames from 'classnames';

import './Checkbox.scss';

type OwnProps = {
  className?: string;
  disabled?: boolean;
  checked?: boolean;
  defaultChecked?: boolean;
  children?: Element<any>;
  onChange?: (e: SyntheticInputEvent) => void;
};

const Checkbox = ({ className, disabled, defaultChecked, checked, onChange, children }: OwnProps) => {
  return (
    <div className={classnames('Checkbox', className)}>
      <label className="Checkbox__label">
        <input type="checkbox" disabled={disabled} checked={checked} defaultChecked={defaultChecked} onChange={onChange} />
        {children}
      </label>
    </div>
  );
};

export default Checkbox;
