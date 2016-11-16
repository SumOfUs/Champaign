// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import './SweetInput.css';

type OwnProps = {
  name: string;
  label: any;
};
export default class SweetInput extends Component {
  props: OwnProps;

  state: { filled: boolean; focused: boolean; };

  constructor(props: OwnProps) {
    super(props);
    this.state = {
      filled: false,
      focused: false,
    };
  }

  toggleFocus(focused: boolean, filled?: boolean = false) {
    this.setState({ focused, filled });
  }



  render() {
    const className = classnames({
      'SweetInput-root': true,
      filled: this.state.filled,
      focused: this.state.focused,
    });

    return(
      <div className={className}>
        <label className="SweetInput-label">
          {this.props.label}
        </label>
        <input
          onFocus={e => this.toggleFocus(true, e.target.value.length > 0)}
          onBlur={e => this.toggleFocus(false, e.target.value.length > 0)}
          type="text"
          className="SweetInput-input"
        />
      </div>
    );
  }
}
