import React from 'react';
import { shallow } from 'enzyme';
import toJSON from 'enzymue-to-json';
import CallToolDrillDown from './CallToolDrillDown';
import { targets } from './call_tool_helpers.test';

const onUpdate = jest.fn();
const propsWithFiltering = {
  targets,
  onUpdate,
  targetByAttributes: ['country', 'state'],
  filters: {},
};

describe('CallToolDrillDown Snapshots', () => {
  it('renders filters when there are targetByAttributes', () => {
    const wrapper = shallow(<CallToolDrillDown {...propsWithFiltering} />);
    expect(toJSON(wrapper)).toMatchSnapshot('CallToolDrillDownWithFilters');
  });
});
