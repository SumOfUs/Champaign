// @flow weak
import React, { Component } from 'react';
import './SweetHTMLSelect.css';

interface SelectOption {
  value: string,
  label: string,
}

export default class SweetHTMLSelect extends Component {
  onChange = (option: SelectOption) => {
    if (this.props.onChange) {
      this.props.onChange(option.value);
    }
  };

  render() {
    const { options, value } = this.props;
    return (
      <select
        className="SweetHTMLSelect"
        value={value || undefined}
        onChange={this.onChange}
      >
        {options.map(({ value, label }) => (
          <option key={value} value={value}>
            {label}
          </option>
        ))}
      </select>
    );
  }
}
