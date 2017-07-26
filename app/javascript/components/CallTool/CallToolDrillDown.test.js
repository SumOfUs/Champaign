import React from 'react';
import { shallow } from 'enzyme';
import toJSON from 'enzyme-to-json';
import CallToolDrillDown from './CallToolDrillDown';
import { targets } from './call_tool_helpers.test';

const onUpdate = jest.fn();
const baseProps = {
  targets,
  onUpdate,
  targetByAttributes: ['country', 'state', 'name'],
  filters: {},
};

describe('CallToolDrillDown Snapshots', () => {
  it('renders filters when there are targetByAttributes', () => {
    const wrapper = shallow(<CallToolDrillDown {...baseProps} />);
    expect(toJSON(wrapper)).toMatchSnapshot('CallToolDrillDownWithFilters');
  });

  it('pre-selects the first property if it is passed in the filter', () => {
    const props = { ...baseProps, filters: { country: 'United States' } };
    const wrapper = shallow(<CallToolDrillDown {...props} />);
    expect(toJSON(wrapper)).toMatchSnapshot('CallToolDrillDownWithFilters');
  });

  it('pre-selects the first two properties if they passed in the filter', () => {
    const props = {
      ...baseProps,
      filters: { country: 'United States', state: 'California' },
    };
    const wrapper = shallow(<CallToolDrillDown {...props} />);
    expect(toJSON(wrapper)).toMatchSnapshot('CallToolDrillDownWithFilters');
  });

  it('pre-selects nothing if the passed filter is not first', () => {
    const props = { ...baseProps, filters: { state: 'California' } };
    const wrapper = shallow(<CallToolDrillDown {...props} />);
    expect(toJSON(wrapper)).toMatchSnapshot('CallToolDrillDownWithFilters');
  });
});
