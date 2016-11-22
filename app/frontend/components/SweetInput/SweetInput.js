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
    if (focused) this.refs.input.focus();
    this.setState({ focused });
  }

  render() {
    const className = classnames({
      'sweet-placeholder__label': true,
      'sweet-placeholder__label--full': !!(this.props.value),
      'sweet-placeholder__label--active': this.state.focused,
      'has-error': !!(this.props.errorMessage),
    });

    return(
      <div className="sweet-placeholder">
        <label className={className} onClick={e => this.toggleFocus(true)}>
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
          className="sweet-placeholder__field"
        />
      </div>
    );
  }
}
