import React, { Component } from 'react';
import classnames from 'classnames';
import Select from 'react-select';
import 'react-select/dist/react-select.css';
import './SweetSelect.scss';

// TODO: deduplicate this (also seen in SweetInput)

export default class SweetSelect extends Component {
  constructor(props) {
    super(props);
    this.state = {
      filled: false,
      focused: false,
    };
  }

  onChange(item) {
    if (this.props.onChange) {
      const value = item ? item.value : '';
      this.props.onChange(value);
    }
  }

  hasError() {
    const { validationState, errorMessage } = this.props;
    if (validationState || validationState === null) {
      return validationState === 'error';
    }
    return !!this.props.errorMessage;
  }

  focus() {
    if (!this.refs.select) return;
    this.refs.select.focus();
  }
  toggleFocus(focused) {
    if (focused) this.refs.select.focus();
    this.setState({ focused });
  }

  render() {
    const className = classnames('sweet-placeholder__label', {
      'sweet-placeholder__label--full':
        !!this.props.value && !this.state.focused,
      'sweet-placeholder__label--active': this.state.focused,
      'has-error': this.hasError(),
    });

    const rootClassName = classnames(
      'SweetSelect',
      'sweet-placeholder',
      this.props.className
    );

    return (
      <div className={rootClassName}>
        <label className={className} onClick={e => this.toggleFocus(true)}>
          {this.props.label}
        </label>
        <Select
          {...this.props}
          ref="select"
          placeholder=""
          openOnFocus={true}
          onFocus={e => this.toggleFocus(true)}
          onBlur={e => this.toggleFocus(false)}
          onChange={this.onChange.bind(this)}
          className={this.hasError() ? 'has-error' : ''}
        />
        <span className="error-msg">{this.props.errorMessage}</span>
      </div>
    );
  }
}
