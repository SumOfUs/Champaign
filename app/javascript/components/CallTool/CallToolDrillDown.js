// @flow
import React, { Component } from 'react';
import { compact, flatten, get, omit, omitBy, startCase, uniq } from 'lodash';
import { valuesForFilter } from './call_tool_helpers';
import SweetSelect from '../../components/SweetSelect/SweetSelect';

import type { Target } from '../../call_tool/CallToolView';

type Filters = { [string]: string };
type OwnProps = {
  targetByAttributes: string[],
  filters: Filters,
  targets: Target[],
  onUpdate: (filters: Filters) => void,
};

export default class CallToolDrillDown extends Component {
  props: OwnProps;

  valuesForSelect(key: string): any[] {
    const values = valuesForFilter(
      this.props.targets,
      this.props.targetByAttributes,
      this.props.filters,
      key
    );
    return values.map(value => ({
      id: `${key}-${value}`,
      label: value,
      value,
    }));
  }

  renderFilter = (key: string, index: number) => {
    const previousKey = this.props.targetByAttributes[index - 1];
    const previousFilter = this.props.filters[previousKey];
    // if we're in the first filter, or if we've selected a previous filter
    if (index === 0 || previousFilter) {
      return (
        <div key={key} style={{ marginBottom: '10px' }}>
          <SweetSelect
            name={`filter-targets-by-attribute-${key}`}
            value={this.props.filters[key]}
            options={this.valuesForSelect(key)}
            label={startCase(key)}
            onChange={(value: string) =>
              this.props.onUpdate(
                omitBy(
                  { ...this.props.filters, [key]: value },
                  (v: string) => !v
                )
              )}
          />
          <div className="clearfix" />
        </div>
      );
    }

    return null;
  };

  render() {
    if (!this.props.targetByAttributes.length) return null;
    return (
      <div className="CallToolDrillDown">
        {this.props.targetByAttributes.map(this.renderFilter)}
      </div>
    );
  }
}
