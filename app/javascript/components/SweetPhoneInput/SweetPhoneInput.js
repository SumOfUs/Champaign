// @flow
import React from 'react';
import InputPhone from 'react-phone-number-input';
import classnames from 'classnames';
import 'react-phone-number-input/rrui.css';
import 'react-phone-number-input/style.css';
import './SweetPhoneInput.css';

type OwnProps = {
  value: ?string,
  onChange: (number: string) => void,
  country?: string,
  countries?: string[],
  nativeExpanded?: boolean,
};

export default function SweetPhoneInput(props: OwnProps) {
  const className = classnames({
    SweetPhoneInput: true,
  });

  return (
    <div className={className}>
      <InputPhone {...props} />
    </div>
  );
}
