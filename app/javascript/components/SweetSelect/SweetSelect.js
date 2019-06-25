// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import Select from 'react-select';
import type { SelectOption } from 'react-select';
// import 'react-select/dist/react-select.css';
import './SweetSelect.scss';

// TODO: deduplicate this (also seen in SweetInput)
export type ValidationState = 'success' | 'warning' | 'error' | null;

type Props = {
  name: string,
  value?: string | number,
  onChange: (value: any) => void,
  options: SelectOption[],
  label?: any,
  clearable?: boolean,
  disabled?: boolean,
  multiple?: boolean,
  errorMessage?: any,
  validationState?: ValidationState,
  className?: string,
};

type State = { filled: boolean, focused: boolean };
export default class SweetSelect extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      filled: false,
      focused: false,
    };
  }

  onChange(item: Object) {
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
  toggleFocus(focused: boolean) {
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
          className="Select"
          classNamePrefix="Select"
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
