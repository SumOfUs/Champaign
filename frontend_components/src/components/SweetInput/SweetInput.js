// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import './SweetInput.css';

type OwnProps = {
  name: string;
  label: any;
  type?: string;
  value?: string;
  onChange?: (value: string) => void;
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

  static defaultProps = {
    name: '',
    label: '',
    type: 'text',
  };

  onChange(value: string) {
    if (this.props.onChange) {
      this.props.onChange(value);
    }
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
          ref="input"
          value={this.props.value}
          name={this.props.name}
          type={this.props.type}
          onChange={e => this.onChange(e.target.value)}
          onFocus={e => this.toggleFocus(true, e.target.value.length > 0)}
          onBlur={e => this.toggleFocus(false, e.target.value.length > 0)}
          className="SweetInput-input"
        />
      </div>
    );
  }
}
