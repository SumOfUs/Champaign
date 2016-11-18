// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import './SweetInput.css';

type OwnProps = {
  name: string;
  label: any;
  value: string;
  type?: string;
  required?: boolean;
  errorMessage?: string;
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
    value: '',
    name: '',
    label: '',
    type: 'text',
    errorMessage: '',
  };

  onChange(value: string) {
    if (this.props.onChange) {
      this.props.onChange(value);
    }
  }

  toggleFocus(focused: boolean) {
    this.setState({ focused });
  }

  render() {
    const className = classnames({
      'SweetInput-root': true,
      filled: !!(this.props.value),
      focused: this.state.focused,
      invalid: !!(this.props.errorMessage),
    });

    return(
      <div className={className}>
        <label className="SweetInput-label">
          {this.props.label}
        </label>
        <span className="SweetInput-error">{this.props.errorMessage}</span>
        <input
          ref="input"
          value={this.props.value || ''}
          name={this.props.name}
          type={this.props.type}
          required={this.props.required}
          onChange={e => this.onChange(e.target.value)}
          onFocus={e => this.toggleFocus(true)}
          onBlur={e => this.toggleFocus(false)}
          className="SweetInput-input"
        />
      </div>
    );
  }
}
