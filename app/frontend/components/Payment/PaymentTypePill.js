import React from 'react';
import classnames from 'classnames';
import './PaymentTypePill.scss';

type OwnProps = {
  checked: boolean;
  children: React$Element<any>;
  onChange: (value: string) => void;
  activeColor?: string;
};

export default function PaymentTypePill(props: OwnProps) {
  const className = classnames({
    PaymentTypePill: true,
    'PaymentTypePill--active': props.checked,
    'PaymentTypePill--disabled': props.disabled,
  });

  let style = {};
  if (props.checked && props.activeColor) {
    style = { backgroundColor: props.activeColor };
  }

  return (
    <div className={className} style={style}>
      <label className="PaymentTypePill__label">
        <input
          type="radio"
          name="paymentOption"
          checked={props.checked}
          onChange={(e) => props.onChange(e.currentTarget.checked)} />
          {props.children}
      </label>
    </div>
  );
}
