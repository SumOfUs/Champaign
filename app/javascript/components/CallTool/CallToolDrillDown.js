// @flow
import React, { Component } from 'react';
import {
  compact,
  flatten,
  get,
  omit,
  omitBy,
  sample,
  startCase,
  uniq,
} from 'lodash';
import {
  filterTargets,
  targetsWithFields,
  valuesForFilter,
} from './call_tool_helpers';
import SweetSelect from '../../components/SweetSelect/SweetSelect';
import type { TargetWithFields } from './call_tool_helpers';

type Filters = { [string]: string };
type Props = {
  targetByAttributes: string[],
  targets: TargetWithFields[],
  onUpdate: (target: ?TargetWithFields) => void,
  filters?: Filters,
};

type State = {
  filters: Filters,
  targets: TargetWithFields[],
};
export default class CallToolDrillDown extends Component {
  props: Props;
  state: State;

  constructor(props: Props) {
    super(props);

    const filters = Object.assign({}, props.filters);
    this.state = {
      filters,
      targets: filterTargets(props.targets, filters),
    };
  }

  componentDidMount() {
    this.fn();
  }

  sampleTarget(targets: TargetWithFields[]): TargetWithFields {
    return sample(targets);
  }

  valuesForSelect(key: string): any[] {
    const values = valuesForFilter(
      this.props.targets,
      this.props.targetByAttributes,
      this.state.filters,
      key
    );
    return values.map(value => ({
      id: `${key}-${value}`,
      label: value,
      value,
    }));
  }

  updateFilters(filters: Filters) {
    this.setState(
      (prevState: State) => ({
        ...prevState,
        filters,
        targets: filterTargets(this.props.targets, filters),
      }),
      () => this.fn()
    );
  }

  fn() {
    if (
      Object.keys(this.state.filters).length ===
      this.props.targetByAttributes.length
    ) {
      this.props.onUpdate(this.sampleTarget(this.state.targets));
    } else {
      this.props.onUpdate(null);
    }
  }

  renderFilter = (key: string, index: number) => {
    const attrs = this.props.targetByAttributes;
    const previousKey = attrs[index - 1];
    const previousFilter = this.state.filters[previousKey];
    // if we're in the first filter, or if we've selected a previous filter
    if (index === 0 || previousFilter) {
      return (
        <div key={key} style={{ marginBottom: '10px' }}>
          <SweetSelect
            name={`filter-targets-by-attribute-${key}`}
            value={this.valueForSelect(key)}
            options={this.valuesForSelect(key)}
            label={startCase(key)}
            clearable={index > 0}
            onChange={(value: string) => {
              const updatedFilters = { ...this.state.filters, [key]: value };
              const discardFn = (v: string, k: string) =>
                !v || attrs.indexOf(k) > index;
              this.updateFilters(omitBy(updatedFilters, discardFn));
            }}
          />
          <div className="clearfix" />
        </div>
      );
    }

    return null;
  };

  valueForSelect(key) {
    if (this.state.filters[key] && this.state.targets.length) {
      return this.state.targets[0][key];
    }
  }

  render() {
    if (!this.props.targetByAttributes.length) return null;
    return (
      <div className="CallToolDrillDown">
        {this.props.targetByAttributes.map(this.renderFilter)}
      </div>
    );
  }
}
