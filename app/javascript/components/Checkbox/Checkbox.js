import React from 'react';
import classnames from 'classnames';

import './Checkbox.scss';

const Checkbox = props => {
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
