//  weak
import React, { Component } from 'react';
import classnames from 'classnames';

export default class SweetInput extends Component {
  constructor(props) {
    super(props);
    this.state = {
      focused: false,
    };
  }

  static defaultProps = {
    value: '',
    name: '',
    label: '',
    type: 'text',
    errorMessage: '',
    hasError: false,
  };

  hasError() {
    return this.props.hasError || !!this.props.errorMessage;
  }

  onChange = e => {
    if (this.props.onChange) {
      this.props.onChange(e.currentTarget.value);
    }
  };

  onFocus = () => {
    this.refs.input.focus();
    this.setState({ focused: true });
  };

  onBlur = () => this.setState({ focused: false });

  render() {
    const className = classnames('sweet-placeholder', this.props.className);
    const labelClassName = classnames({
      'sweet-placeholder__label': true,
      'sweet-placeholder__label--full':
        !!this.props.value && !this.state.focused,
      'sweet-placeholder__label--active': this.state.focused,
      'has-error': this.hasError(),
    });
    const inputClassName = classnames('sweet-placeholder__field', {
      'has-error': this.hasError(),
    });

    if (process.env.NODE_ENV === 'development' && this.props.errorMessage) {
      console.warn(
        "SweetInput's `errorMessage` prop will be deprecated. Please use `hasError` (boolean)."
      );
    }

    return (
      <div className={className}>
        <label className={labelClassName} onClick={this.onFocus}>
          {this.props.label}
        </label>
        <input
          ref="input"
          value={this.props.value || ''}
          name={this.props.name}
          type={this.props.type}
          required={this.props.required}
          onChange={this.onChange}
          onFocus={this.onFocus}
          onBlur={this.onBlur}
          className={inputClassName}
        />
        {this.props.errorMessage && (
          <span className="error-msg">{this.props.errorMessage}</span>
        )}
      </div>
    );
  }
}
