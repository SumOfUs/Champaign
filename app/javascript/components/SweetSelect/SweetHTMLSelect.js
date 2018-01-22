// @flow weak
import React, { Component } from 'react';
import classnames from 'classnames';
import './SweetHTMLSelect.css';

interface SelectOption {
  value: string,
  label: string,
}

export default class SweetHTMLSelect extends Component {
  onChange = (option: SyntheticInputEvent) => {
    if (this.props.onChange) {
      this.props.onChange(option.target.value);
    }
  };

  render() {
    const { errorMessage, label, options, value } = this.props;
    const rootClassName = classnames('SweetHTMLSelect', this.props.className);

    return (
      <div className={rootClassName}>
        <select value={value || undefined} onChange={this.onChange}>
          <option value="">{label}</option>
          {options.map(({ value, label }) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
        <span className="error-msg">{errorMessage}</span>
      </div>
    );
  }
}
