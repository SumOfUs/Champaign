// @flow

import React from 'react';
import type { Element } from 'react';

// <ShowIf /> *renders* its children, but hides them with CSS if
// `props.condition` is falsy, as opposed to not rendering the node at all
// which won't trigger the lifecycle methods. Use this when you want the component
// to be mounted but not displayed, and its lifecycle methods to be triggered,
// but you don't want to display the component, and you don't want to add that
// show/hide display logic to the child components.
type OwnProps = {
  condition: boolean;
  children?: Element<any>;
};
export default (props: OwnProps) => {
  const style = {};
  let className = 'ShowIf--visible';

  if (!props.children) return null;

  if (!props.condition) {
    style.display = 'none';
    className = 'ShowIf--hidden';
  }

  return (
    <div style={style} className={'ShowIf '+className}>
      {props.children}
    </div>
  );
};
