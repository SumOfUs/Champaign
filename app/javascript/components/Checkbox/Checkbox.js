// @flow
import React from 'react';
import type { Element } from 'react';
import classnames from 'classnames';

import './Checkbox.scss';

type OwnProps = {
  className?: string,
  disabled?: boolean,
  checked?: boolean,
  defaultChecked?: boolean,
  children?: Element<any>,
  onChange?: (e: SyntheticEvent<HTMLInputElement>) => void,
};

const Checkbox = (props: OwnProps) => {
  return (
    <div className={classnames('Checkbox', props.className)}>
      <label className="Checkbox__label">
        <input
          type="checkbox"
          disabled={props.disabled}
          checked={props.checked}
          defaultChecked={props.defaultChecked}
          onChange={props.onChange}
        />
        {props.children}
      </label>
    </div>
  );
};

export default Checkbox;
