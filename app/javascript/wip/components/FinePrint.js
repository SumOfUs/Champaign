import React from 'react';
import type { Element } from 'react';
import './FinePrint.css';

type OwnProps = {
  children?: Element<any>;
}

export default function FinePrint(props: OwnProps) {
  return <div className="FinePrint">{props.children}</div>;
}
