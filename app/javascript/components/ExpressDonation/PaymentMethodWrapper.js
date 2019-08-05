import React from 'react';

export default function PaymentMethodWrapper(props) {
  return (
    <div className="PaymentMethodWrapper">
      <i className="PaymentMethodWrapper__icon fa fa-credit-card" />
      {props.children}
    </div>
  );
}
