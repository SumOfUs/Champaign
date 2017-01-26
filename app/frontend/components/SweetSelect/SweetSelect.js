// @flow
import React, { Component } from 'react';
import classnames from 'classnames';
import Select from 'react-select';
import './SweetSelect.scss';

type Props = {
  name: string;
  value?: string;
  onChange: (value: any) => void;
  options?: any[];
  label?: any;
  disabled?: boolean;
  multiple?: boolean;
  errorMessage?: any;
};

export default class SweetSelect extends Component {
  props: Props;

  state: { filled: boolean; focused: boolean; };

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
    return !!(this.props.errorMessage);
  }

  toggleFocus(focused: boolean) {
    if (focused) this.refs.select.focus();
    this.setState({ focused });
  }

  render() {
    const className = classnames({
      'sweet-placeholder__label': true,
      'sweet-placeholder__label--full': !!this.props.value && !this.state.focused,
      'sweet-placeholder__label--active': this.state.focused,
      'has-error': this.hasError(),
    });

    return (<div className="sweet-placeholder SweetSelect">
        <label className={className} onClick={e => this.toggleFocus(true)}>
          {this.props.label}
        </label>
        <Select {...this.props}
          ref="select"
          placeholder=''
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
