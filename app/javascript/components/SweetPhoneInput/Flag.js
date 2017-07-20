// @flow
import React from 'react';
import classnames from 'classnames';
import './Flag.scss';

type Props = {
  countryCode?: string,
};

export default ({ countryCode }: Props) => {
  const code = countryCode ? countryCode.toLowerCase() : '';
  const className = classnames('Flag', code);
  return <span className={className} />;
};
